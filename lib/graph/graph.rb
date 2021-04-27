require File.dirname(__FILE__) + "/../../modules/databaseable"

module Graph
	class Graph
		extend Databaseable

		attr_reader :edges, :vertices

		def initialize(edges:, vertices:)
			@edges = edges
			@vertices = vertices
		end
	end
end