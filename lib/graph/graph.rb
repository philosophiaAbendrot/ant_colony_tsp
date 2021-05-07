module Graph
	class Graph
		def initialize(edges_input:, vertices_input:, vertex_class:, edge_class:)
			@vertex_class = vertex_class
			@edge_class = edge_class

			# initialize edges and Vertices
			initialize_edges(edges_input)
			initialize_vertices(vertices_input)
			connect_edges_with_vertices
		end

		private 

		def initialize_edges(edges_input)
			# edge input format
			# [id: integer, start_vertex_id: integer, end_vertex_id: integer, cost_of_traversal: double]

			raise ArgumentError.new("Edges input is not an array") unless edges_input.is_a?(Array)

			edges_input.each do |edge_input|
				edge_input.merge!(vertex_class: @vertex_class)

				if edge_input.is_a?(Hash)
					@edge_class.new(edge_input)
				else
					raise ArgumentError.new("Edge input is not in hash format")
				end
			end
		end

		def initialize_vertices(vertices_input)
			# vertex input format
			# [external_vertex_id: integer, x_pos: float, y_pos: float]

			raise ArgumentError.new("Vertices input is not an array") unless vertices_input.is_a?(Array)

			vertices_input.each do |vertex_input|
				if vertex_input.is_a?(Hash)
					@vertex_class.new(vertex_input)
				else
					raise ArgumentError.new("Vertex input is not in hash format")
				end
			end
		end

		def connect_edges_with_vertices
			@edge_class.all.each do |edge|
				edge.start_vertex.outgoing_edge_ids << edge.id
				edge.end_vertex.incoming_edge_ids << edge.id
			end
		end
	end
end