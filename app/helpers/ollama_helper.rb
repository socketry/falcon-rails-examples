require "markly"

module OllamaHelper
  def ollama_response_html(content)
    sanitize(Markly.render_html(content, extensions: %i[autolink table]))
  end
end
