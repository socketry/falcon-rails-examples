Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "welcome#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Streaming Example:
  get 'streaming/index'
  get 'streaming/stream'

  # Chat Example:
  get "chat/index"
  connect "chat/connect"

  # Game Example:
  get "game/index"
  connect "game/live"

  # Job Example:
  get "job/index"
  post "job/execute"

  # Ollama Example:
  get "ollama/index"
  connect "ollama/live"

  # Flappy Example:
  get "flappy/index"
  connect "flappy/live"

  # SSE Example:
  get 'sse/index'
  get 'sse/events'
end
