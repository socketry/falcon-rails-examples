import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["prompt", "send", "messages", "status"]
  static values = { conversation: String, url: String }

  connect() {
    this.connected = false
    this.pending = null
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create(
      { channel: "OllamaChannel", conversation: this.conversationValue },
      {
        connected: () => {
          this.connected = true
          this.statusTarget.textContent = this.pending ? "Generating…" : "Ready."
          this.updateControls()
        },
        disconnected: () => {
          this.connected = false
          this.statusTarget.textContent = "Updates disconnected. Reconnecting…"
          this.updateControls()
        },
        rejected: () => {
          this.connected = false
          this.statusTarget.textContent = "Subscription rejected. Reload to start a new conversation."
          this.updateControls()
        },
        received: (data) => {
          if (this.pending && data.request_id === this.pending.id) {
            this.pending.response.innerHTML = data.html
            this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
          }
        },
      },
    )
    this.updateControls()
  }

  disconnect() {
    this.pending?.abort.abort()
    this.pending = null
    this.subscription.unsubscribe()
    this.consumer.disconnect()
  }

  async submit(event) {
    event.preventDefault()
    const prompt = this.promptTarget.value.trim()
    if (!this.connected || this.pending || !prompt) return

    this.addMessage("prompt", prompt)
    const pending = {
      id: crypto.randomUUID(),
      response: this.addMessage("response", ""),
      abort: new AbortController(),
    }
    this.pending = pending
    this.promptTarget.value = ""
    this.statusTarget.textContent = "Generating…"
    this.updateControls()

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
        body: JSON.stringify({
          conversation: this.conversationValue,
          request_id: pending.id,
          prompt,
        }),
        signal: pending.abort.signal,
      })
      if (!response.ok) throw new Error("Generation failed. Check that Ollama is running and a model is installed.")

      // The final HTTP response also recovers any missed Cable updates.
      const data = await response.json()
      if (this.pending !== pending) return
      pending.response.innerHTML = data.html
      this.statusTarget.textContent = "Reply saved."
    } catch (error) {
      if (error.name !== "AbortError" && this.pending === pending) this.statusTarget.textContent = error.message
    } finally {
      if (this.pending === pending) {
        this.pending = null
        if (this.element.isConnected) this.updateControls()
      }
    }
  }

  updateControls() {
    this.sendTarget.disabled = !this.connected || Boolean(this.pending)
    this.promptTarget.disabled = this.sendTarget.disabled
  }

  addMessage(kind, content) {
    const message = document.createElement("div")
    message.className = "message"
    const text = document.createElement(kind === "response" ? "div" : "p")
    text.className = kind
    text.textContent = content
    message.append(text)
    this.messagesTarget.append(message)
    return text
  }
}
