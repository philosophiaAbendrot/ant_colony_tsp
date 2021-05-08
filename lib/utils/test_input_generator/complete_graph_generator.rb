module TestInputGenerator
	class CompleteGraphGenerator < BaseGraphGenerator
		def initialize(num_vertices:)
			@num_vertices = num_vertices
		end

		private

		def generate_edge_inputs(vertex_outputs)
			edge_outputs = []
			vertex_output_ids = vertex_outputs.map { |el| el[:id] }
			edge_id = 0

			vertex_output_ids.each do |start_vertex_id|
				vertex_output_ids.each do |end_vertex_id|
					if start_vertex_id != end_vertex_id
						# calculate cost of traversal
						difficulty = Math.exp(rand - 0.5)
						cost_of_traversal = @adj_mat[start_vertex_id][end_vertex_id] * difficulty
						edge_outputs << { id: edge_id, start_vertex_id: start_vertex_id, end_vertex_id: end_vertex_id, cost_of_traversal: cost_of_traversal }
						edge_id += 1
					end
				end
			end

			edge_outputs
		end
	end
end