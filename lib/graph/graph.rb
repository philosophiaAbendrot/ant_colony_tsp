module Graph
	class Graph
		def initialize(edge_inputs:, vertex_inputs:)
			# initialize edges and Vertices
			initialize_edges(edge_inputs)
			initialize_vertices(vertex_inputs)
			connect_edges_with_vertices
		end

		def self.set_config(config)
			@@config = config

			@@vertex_class = config.vertex_class
			@@edge_class = config.edge_class
			@@initial_trail_density = config.initial_trail_density
			@@rho = config.rho
		end

		private 

		def initialize_edges(edge_inputs)
			# edge input format
			# [id: integer, start_vertex_id: integer, end_vertex_id: integer, cost_of_traversal: double]

			raise ArgumentError.new("Edges input is not an array") unless edge_inputs.is_a?(Array)


			edge_inputs.each do |edge_input|
				if edge_input.is_a?(Hash)
					@@edge_class.new(edge_input)
				else
					raise ArgumentError.new("Edge input is not in hash format")
				end
			end

			# set initial trail densities
			@@edge_class.set_trail_densities(@trail_density)
			# set trail persistence
			@@edge_class.set_trail_persistence(@@rho)
		end

		def initialize_vertices(vertex_inputs)
			# vertex input format
			# [external_vertex_id: integer, x_pos: float, y_pos: float]

			raise ArgumentError.new("Vertices input is not an array") unless vertex_inputs.is_a?(Array)

			vertex_inputs.each do |vertex_input|
				if vertex_input.is_a?(Hash)
					@@vertex_class.new(vertex_input)
				else
					raise ArgumentError.new("Vertex input is not in hash format")
				end
			end
		end

		def connect_edges_with_vertices
			@@edge_class.all.each do |edge|
				edge.start_vertex.outgoing_edge_ids << edge.id
				edge.end_vertex.incoming_edge_ids << edge.id
			end
		end
	end
end