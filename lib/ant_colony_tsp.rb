file_paths = [
	"/../graph/edge.rb", "/../graph/vertex.rb", "/../graph/graph.rb",
	"/../modules/databaseable.rb", "/../ant.rb"
]

file_paths.each do |path|
	require File.dirname(__FILE__) + path
end

class AntColonyTsp
	attr_reader :time

	def initialize(edges:, vertices:)
		@time = 0
		# initialize graph
		@graph = Graph.new(edges: edges, vertices: vertices)
	end	
end