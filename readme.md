# Falcon Rails Examples

This repository contains a comprehensive collection of examples demonstrating the capabilities of [Falcon](https://github.com/socketry/falcon), a high-performance web server for Ruby. Falcon excels at handling concurrent connections, streaming responses, and real-time features that traditional Ruby web servers struggle with.

## What is Falcon?

Falcon is an async web server built on top of the [Async](https://github.com/socketry/async) framework. It provides:

- **High concurrency** - Handle thousands of concurrent connections efficiently.
- **HTTP/2 support** - Native HTTP/2 with server push capabilities.
- **Streaming responses** - Perfect for real-time applications.
- **WebSocket support** - Built-in WebSocket handling.
- **Low latency** - Excellent performance for real-time features.

## Examples Overview

This application showcases 7 different examples, each demonstrating specific Falcon capabilities:

### 🌊 Streaming Example
**Demonstrates**: HTTP response streaming and progressive rendering
- Streams a "99 bottles of beer" countdown in real-time
- Shows how Falcon handles long-running streaming responses
- Perfect for progress indicators, live logs, or data feeds

### 💬 Chat Example
**Demonstrates**: WebSocket real-time communication with Redis pub/sub
- Multi-user real-time chat application
- WebSocket connections managed by Falcon
- Redis backend for message broadcasting across multiple clients
- Showcases Falcon's excellent WebSocket performance

### 🎮 Game Example
**Demonstrates**: Interactive real-time applications with Live::View
- Real-time interactive game using WebSocket
- Demonstrates Live::View framework integration
- Shows how Falcon handles interactive, stateful applications

### ⚡ Job Example
**Demonstrates**: Background job processing integration
- ActiveJob background job execution
- Job queue management and monitoring
- Shows how Falcon integrates with Rails' job processing

### 🤖 Ollama Example
**Demonstrates**: AI/LLM streaming integration
- Streaming AI chat interface using Ollama
- Real-time AI response streaming
- Persistent conversation storage
- Perfect example of Falcon's streaming capabilities with AI

### 🐦 Flappy Example
**Demonstrates**: Real-time game with Live::View
- Complete Flappy Bird game implementation
- Real-time game state synchronization
- High-performance game loop over WebSocket
- Demonstrates Falcon's low-latency capabilities

### 📡 SSE Example
**Demonstrates**: Server-Sent Events (EventSource)
- Server-Sent Events for one-way real-time updates
- Continuous timestamp updates delivered once per second
- Alternative to WebSocket for simple real-time updates

## Getting Started

### Prerequisites

- Ruby (version specified in `.ruby-version`).
- Redis server running on localhost (required by the chat and job examples).
- SQLite3 (for database).
- Ollama with at least one installed model (required only by the Ollama example).

### Installation

Clone the repository:

```bash
git clone https://github.com/socketry/falcon-rails-examples.git
cd falcon-rails-examples
```

Install dependencies:

```bash
bundle install
```

Prepare the database:

```bash
bin/rails db:prepare
```

Ensure Redis is running:

```bash
redis-server
```

Start the Falcon server. Preloading Rails before Falcon forks avoids loading
native libraries for the first time inside worker processes:

```bash
bundle exec falcon serve --preload config/environment
```

The application will be available at `https://localhost:9292` (note: Falcon serves HTTPS by default).

To process jobs, start the Active Job server in another terminal after Redis is
running:

```bash
bundle exec async-job-adapter-active_job-server
```

For the Ollama example, make sure Ollama is running and install the default
model:

```bash
ollama pull llama3.2
```

You can select a different model with `ASYNC_OLLAMA_MODEL`. If the selected
model is unavailable, the example uses the first model installed in Ollama.

### Running with Instrumentation

If you have the `datadog-agent` running, you can enable instrumentation for Falcon:

```bash
TRACES_BACKEND=traces/backend/datadog METRICS_BACKEND=metrics/backend/datadog bundle exec falcon serve --preload config/environment
```

If you'd like to log metrics and traces to the terminal:

```bash
TRACES_BACKEND=traces/backend/console METRICS_BACKEND=metrics/backend/console bundle exec falcon serve --preload config/environment
```

## Technical Architecture

Each example demonstrates different aspects of Falcon's architecture:

- **Streaming Controller**: Basic HTTP streaming with `Rack::Response`
- **WebSocket Integration**: Using `Async::WebSocket::Adapters::Rails`
- **Live::View Framework**: Real-time view updates over WebSocket
- **Background Jobs**: Rails Active Job processing with `async-job-adapter-active_job` and Redis
- **Redis Integration**: Pub/sub messaging for real-time features
- **AI Integration**: Streaming LLM responses with `async-ollama`

## Performance Benefits

Falcon provides significant performance improvements for:

- **Real-time applications**: WebSocket and SSE connections
- **Streaming responses**: Large file downloads, progress updates
- **Concurrent users**: Handling thousands of simultaneous connections
- **I/O intensive operations**: Database queries, API calls, file operations

## Learn More

- [Falcon Server](https://github.com/socketry/falcon)
- [Async Framework](https://github.com/socketry/async)
- [Live::View Framework](https://github.com/socketry/live)
