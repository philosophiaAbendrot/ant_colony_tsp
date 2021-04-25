module Graph
	class Graph
		attr_reader :edges, :vertices

		def initialize(edges:, vertices:)
			@edges = edges
			@vertices = vertices
		end
	end
end