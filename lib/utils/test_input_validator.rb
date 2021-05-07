require 'json'
require 'pqueue'

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
			@vertex_hash = initialize_vertex_hash
			@edge_inputs = edge_inputs
			@edge_mat = initialize_edge_matrix
		end
	end

	def execute
		start_vertex_id = vertex_inputs[0][:id]
		instance = Dijkstra.new(vertex_inputs: @vertex_inputs.dup, edge_inputs: @edge_inputs.dup)
		instance.execute(start_vertex_id)
	end
end