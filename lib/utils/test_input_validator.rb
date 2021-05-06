require 'json'

class TestInputValidator
	def initialize
		@vertex_inputs = JSON.parse(File.read(__dir__ + "/test_data/test_vertex_inputs.json"))
		@edge_inputs = JSON.parse(File.read(__dir__ + "/test_data/test_edge_inputs.json"))
	end

	def self.execute
		new.execute
		true
	end

	class Dijkstra
		def initialize(vertex_inputs:, edge_inputs:)
			@vertex_inputs = vertex_inputs
			@edge_inputs = edge_inputs
		end

		def execute(start_vertex_id)
			@dist = {}
			@prev = {}
			queue = []

			@vertex_inputs.each do |vertex_input|
				@dist[vertex_input[:id]] = Float::INFINITY
				@prev[vertex_input[:id]] = nil
				queue << vertex_input
			end

			@dist[start_vertex_id] = 0
			
		end
	end

	def execute
		start_vertex_id = vertex_inputs[0][:id]
		instance = Dijkstra.new(vertex_inputs: @vertex_inputs.dup, edge_inputs: @edge_inputs.dup)
		instance.execute(start_vertex_id)
	end
end