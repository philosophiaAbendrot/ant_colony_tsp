module TestInputGenerator
	class IncompleteGraphGenerator
		def initialize(num_edges:, num_vertices:)
			@num_edges = num_edges
			@num_vertices = num_vertices
		end

		def execute
			vertex_outputs = generate_vertex_inputs
			initialize_adjacency_matrix
			edge_outputs = generate_edge_inputs(vertex_outputs)

			[vertex_outputs, edge_outputs]
		end

		private

		def generate_vertex_inputs
			vertex_outputs = []

			for i in 0..@num_vertices - 1
				vertex_outputs << { id: i, x_pos: (40 * rand - 20).round(2), y_pos: (40 * rand - 20).round(2) }
			end

			vertex_outputs
		end

		def generate_edge_inputs(vertex_outputs)
			edge_outputs = []
			vertex_output_ids = vertex_outputs.map { |el| el[:id] }

			edge_id = 0

			# make sure every vertex is connected to at least two other vertices
			for vertex_output in vertex_outputs
				while true
					vertex_a_id = vertex_output[:id]

					vertex_b_id, vertex_c_id = vertex_outputs.reject { |vertex_data| vertex_data[:id] == vertex_a_id }.sample(2).map { |el| el[:id] }

					# check if an edge already exists
					unless duplicate_edge_exists?(vertex_a_id, vertex_b_id)
						edge_outputs << { id: edge_id, start_vertex_id: vertex_a_id, end_vertex_id: vertex_b_id }
						edge_outputs << { id: edge_id + 1, start_vertex_id: vertex_b_id, end_vertex_id: vertex_a_id }

						edge_outputs << { id: edge_id + 2, start_vertex_id: vertex_a_id, end_vertex_id: vertex_c_id }
						edge_outputs << { id: edge_id + 3, start_vertex_id: vertex_c_id, end_vertex_id: vertex_a_id }

						# update adj matrix with a placeholder value
						@adj_mat[vertex_a_id][vertex_b_id] = 0
						@adj_mat[vertex_b_id][vertex_a_id] = 0
						@adj_mat[vertex_a_id][vertex_c_id] = 0
						@adj_mat[vertex_c_id][vertex_a_id] = 0
						edge_id += 4
						break
					end
				end
			end


			for i in 0..((@num_edges - edge_outputs.length) / 2) - 1
				# make additional edges between random vertices

				while true
					vertex_a, vertex_b = vertex_outputs.sample(2)

					unless duplicate_edge_exists?(vertex_a[:id], vertex_b[:id])
						edge_outputs << { id: edge_id, start_vertex_id: vertex_a[:id], end_vertex_id: vertex_b[:id] }
						edge_outputs << { id: edge_id + 1, start_vertex_id: vertex_b[:id], end_vertex_id: vertex_a[:id] }
						# update adj matrix with a placeholder value
						@adj_mat[vertex_a[:id]][vertex_b[:id]] = 0
						@adj_mat[vertex_b[:id]][vertex_a[:id]] = 0
						edge_id += 2
						break
					end
				end
			end

			# once all edges are generated, calculate the cost of traversal by multiplying distance between
			# start and end vertex and a random "difficulty" factor
			for i in 0..edge_outputs.length - 1
				edge_output = edge_outputs[i]
				difficulty = Math.exp(rand - 0.5)

				start_vertex_data = vertex_outputs[edge_output[:start_vertex_id]]
				end_vertex_data = vertex_outputs[edge_output[:end_vertex_id]]

				distance = Math.sqrt((end_vertex_data[:x_pos] - start_vertex_data[:x_pos])**2 + (end_vertex_data[:y_pos] - start_vertex_data[:y_pos])**2)
				edge_output[:cost_of_traversal] = (distance * difficulty).round(2)
				# update adj matrix with cost of traversal
				@adj_mat[start_vertex_data[:id]][end_vertex_data[:id]] = edge_output[:cost_of_traversal]
			end

			edge_outputs
		end

		def initialize_adjacency_matrix
			@adj_mat = Array.new(@num_vertices) { Array.new(@num_vertices) { -1 } }
		end

		def duplicate_edge_exists?(vertex_a_id, vertex_b_id)
			@adj_mat[vertex_a_id][vertex_b_id] != -1
		end
	end
end