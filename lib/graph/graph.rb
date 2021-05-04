module Graph
	class Graph
		def initialize(edges_input:, vertices_input:, vertex_class:, edge_class:)
			@vertex_class = vertex_class
			@edge_class = edge_class

			# initialize edges and Vertices
			initialize_edges(edges_input)
			initialize_vertices(vertices_input)
			populate_incoming_and_outgoing_edges_on_vertices
		end

		private 

		def initialize_edges(edges_input)
			# edge input format
			# [id: integer, start_vertex_id: integer, end_vertex_id: integer, cost_of_traversal: double]

			raise ArgumentError.new("Edges input is not an array") unless edges_input.is_a?(Array)

			edges_input.each do |edge|
				if edge.is_a?(Array) && edge[0].is_a?(Integer) && edge[1].is_a?(Integer) && edge[2].is_a?(Integer) && edge[3].is_a?(Float)
					@edge_class.new(id: edge[0], start_vertex_id: edge[1], end_vertex_id: edge[2], cost_of_traversal: edge[3], vertex_class: @vertex_class)
				else
					raise ArgumentError.new("Invalid input for edges entry")
				end
			end
		end

		def initialize_vertices(vertices_input)
			# vertex input format
			# [external_vertex_id: integer, x_pos: float, y_pos: float]

			raise ArgumentError.new("Vertices input is not an array") unless vertices_input.is_a?(Array)

			vertices_input.each do |vertex|
				if vertex.is_a?(Array) && vertex[0].is_a?(Integer) && vertex[1].is_a?(Float) && vertex[2].is_a?(Float)
					@vertex_class.new(id: vertex[0], x_pos: vertex[1], y_pos: vertex[2])
				else
					raise ArgumentError.new("Invalid input for vertex entry")
				end
			end
		end

		def populate_incoming_and_outgoing_edges_on_vertices
			@edge_class.all.each do |edge|
				edge.start_vertex.outgoing_edge_ids << edge.id
				edge.end_vertex.incoming_edge_ids << edge.id
			end
		end
	end
end