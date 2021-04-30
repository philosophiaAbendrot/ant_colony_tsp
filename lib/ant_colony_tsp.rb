require "modules/databaseable"
require "ant"

class AntColonyTsp
	attr_reader :time

	def initialize(edges:, vertices:)
		@time = 0
		# initialize graph
		@graph = Graph.new(edges: edges, vertices: vertices)
	end	
end