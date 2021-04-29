paths = []
paths += Dir[File.dirname(__FILE__) + "/modules/**/*.rb"]
paths += Dir[File.dirname(__FILE__) + "/ant.rb"]

# Dir[File.dirname(__FILE__) + "/modules/**/*.rb"].each { |path| require path }
# Dir[File.dirname(__FILE__) + "/ant.rb"].each { |path| require path }
paths.each { |path| require path }

class AntColonyTsp
	attr_reader :time

	def initialize(edges:, vertices:)
		@time = 0
		# initialize graph
		@graph = Graph.new(edges: edges, vertices: vertices)
	end	
end