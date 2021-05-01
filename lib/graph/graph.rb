module Graph
	class Graph
		attr_reader :edges, :vertices

		def initialize(edges:, vertices:, vertex_class:, edge_class:)
			@vertex_class = vertex_class
			@edge_class = edge_class

			# initialize edges and vertices

			# edge input format
			# [id: integer, start_vertex_id: integer, end_vertex_id: integer, cost_of_traversal: double]

			raise ArgumentError.new("Edges input is not an array") unless edges.is_a?(Array)

			edges.each do |edge|
				if edge.is_a?(Array) && edge[0].is_a?(Integer) && edge[1].is_a?(Integer) && edge[2].is_a?(Integer) && edge[3].is_a?(Float)
					@edge_class.new(id: edge[0], start_vertex_id: edge[1], end_vertex_id: edge[2], cost_of_traversal: edge[3])
				else
					raise ArgumentError.new("Invalid input for edges entry")
				end
			end

			# vertex input format
			# [external_vertex_id: integer, x_pos: float, y_pos: float]

			raise ArgumentError.new("Vertices input is not an array") unless vertices.is_a?(Array)

			vertices.each do |vertex|
				if vertex.is_a?(Array) && vertex[0].is_a?(Integer) && vertex[1].is_a?(Float) && vertex[2].is_a?(Float)
					@vertex_class.new(id: vertex[0], x_pos: vertex[1], y_pos: vertex[2])
				else
					raise ArgumentError.new("Invalid input for vertex entry")
				end
			end

			@vertices = Vertex.instances
			@edges = Edge.instances
		end
	end
end