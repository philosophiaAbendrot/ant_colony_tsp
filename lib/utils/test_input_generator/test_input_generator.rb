require 'json'
require_relative "../test_input_validator"
require_relative "base_graph_generator"
require_relative "incomplete_graph_generator"
require_relative "complete_graph_generator"

module TestInputGenerator
	class TestInputGenerator
		def initialize(num_vertices:, num_edges:, complete_graph:)
			@num_vertices = num_vertices
			@num_edges = num_edges

			if complete_graph
				@graph_gen_instance = CompleteGraphGenerator.new(num_vertices: num_vertices)
			else
				@graph_gen_instance = IncompleteGraphGenerator.new(num_vertices: num_vertices, num_edges: num_edges)
			end
		end

		def self.execute(complete_graph:, num_vertices:, num_edges: nil)
			start_time = Time.now

			new(num_vertices: num_vertices, num_edges: num_edges, complete_graph: complete_graph).execute
			end_time = Time.now
			puts "Time taken = #{(end_time - start_time) * 1000} ms"
			true
		end

		def execute
			start_time = Time.now
			try_count = 1

			loop do
				vertex_outputs, edge_outputs = @graph_gen_instance.execute
				# @adj_mat = initialize_adjacency_matrix(vertex_outputs)
				# edge_outputs = generate_edge_inputs(vertex_outputs)
				write_results_to_file(vertex_outputs, edge_outputs)
				valid = TestInputValidator.execute

				break if valid
				try_count += 1
			end
			end_time = Time.now

			puts "Test inputs generated in #{try_count} attempts. Total execution time = #{(end_time - start_time) * 1000} ms"
		end

		private

		def write_results_to_file(vertex_outputs, edge_outputs)
			vertex_input_file_path = File.expand_path("../test_data/test_vertex_inputs.json", __dir__)

			File.open(vertex_input_file_path, "w") do |f|
				f.write("[")

				for i in 0..vertex_outputs.length - 1
					line = vertex_outputs[i]
					f.write(line.to_json)

					if i != vertex_outputs.length - 1
						f.write(",")
					end
				end

				f.write("]")
			end

			edge_input_file_path = File.expand_path("../test_data/test_edge_inputs.json", __dir__)

			File.open(edge_input_file_path, "w") do |f|
				f.write("[")

				for i in 0..edge_outputs.length - 1
					line = edge_outputs[i]
					f.write(line.to_json)

					if i != edge_outputs.length - 1
						f.write(",")
					end
				end

				f.write("]")
			end

			true
		end
	end
end