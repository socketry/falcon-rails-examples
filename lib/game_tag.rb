# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'live'
require_relative 'messages'

class GameTag < Live::View
	ROBOT = "🤖"
	KITTEN = "🐱"

	SYMBOLS = [
		"🌳",
		"🌲",
		"🌴",
		"🌵",
		"🌾",
		"🌿",
		"🍀",
		"🍁",
		"🍂",
		"🍃",
		"🍄",
		"🌰",
		"🐚",
		"🌱",
		"🌼",
		"🌻",
		"🌺",
		"🌹",
		"🌷",
		"🌸",
		"💐",
		"🔨",
		"🔧",
		"🔩",
		"🔫",
		"🔪",
		"🔬",
		"🔭",
		"📡",
		"💉",
		"💊",
		"🔮",
		"🔑",
		"🔺",
		"🔻",
		"🔳",
		"🔲",
		"🔴",
		"🔵",
		"🔷",
		"🔶",
		"🔹",
		"🔸",
		"🔘",
	]
	
	class Board
		def initialize(width, height)
			@width = width
			@height = height
			@data = Array.new(@width) do |x|
				Array.new(@height)
			end
		end
		
		attr :width
		attr :height
		attr :data
		
		def generate(seed, density: 0.1)
			count = (@width * @height * density).to_i
			random = Random.new(seed)
			
			count.times do
				x = random.rand(@width)
				y = random.rand(@height)
				symbol = SYMBOLS[random.rand(SYMBOLS.size)]
				message = MESSAGES[random.rand(MESSAGES.size)]
				
				@data[x][y] = [symbol, message]
			end
			
			x = random.rand(@width)
			y = random.rand(@height)
			
			@data[x][y] = [KITTEN, "A kitten!"]
		end
	end
	
	def initialize(...)
		super
		
		# Defaults:
		@data[:seed] ||= Random.new_seed
		@data[:width] ||= 10
		@data[:height] ||= 10
		@data[:x] ||= @data[:width].to_i / 2
		@data[:y] ||= @data[:height].to_i / 2
	end
	
	def board
		@board ||= Board.new(@data[:width].to_i, @data[:height].to_i).tap do |board|
			board.generate(@data[:seed].to_i)
		end
	end
	
	def bind(page)
		super(page)
		
		# run!
	end
	
	def handle(event)
		# Console.info(self, "handle", event.inspect)
		
		if event[:type] == "keydown"
			detail = event[:detail]
			
			case detail[:code]
			when "KeyW", "ArrowUp"
				@data[:y] = (@data[:y].to_i - 1) % board.height
			when "KeyS", "ArrowDown"
				@data[:y] = (@data[:y].to_i + 1) % board.height
			when "KeyA", "ArrowLeft"
				@data[:x] = (@data[:x].to_i - 1) % board.width
			when "KeyD", "ArrowRight"
				@data[:x] = (@data[:x].to_i + 1) % board.width
			end
			
			# Redraw the game:
			self.update!
		end
	end
	
	def forward_keypress
		"event.preventDefault(); live.forwardEvent(#{JSON.dump(@id)}, event, {code: event.code})"
	end
	
	def render(builder)
		builder.tag(:div, class: "game", tabIndex: 0, onkeydown: forward_keypress) do
			builder.tag(:table, class: "board") do
				board.height.times do |y|
					builder.tag(:tr) do
						board.width.times do |x|
							builder.tag(:td, class: "cell") do
								symbol, message = board.data[x][y]
								
								if x == @data[:x].to_i and y == @data[:y].to_i
									builder.text(ROBOT)
								else
									builder.text(symbol)
								end
							end
						end
					end
				end
			end
			
			builder.tag(:div, class: "message") do
				symbol, message = board.data[@data[:x].to_i][@data[:y].to_i]
				
				if message
					builder.text(message)
				end
			end
		end
	end
end
