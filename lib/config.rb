class Config
	attr_accessor :num_ants, :num_iterations, :rho, :alpha, :beta, :initial_trail_density, :q,
								:vertex_class, :edge_class, :ant_class, :rand_gen, :graph_class

	def initialize
		# set default values which user can override
		@num_ants = 30
		@num_iterations = 50
		@rho = 0.8
		@alpha = 1
		@beta = 1
		@initial_trail_density = 0.05
		@q = 100
		@edge_class = Graph::Edge
		@vertex_class = Graph::Vertex
		@graph_class = Graph::Graph
		@ant_class = Ant::Ant
		@rand_gen = RandGen
	end

	def process_configs
		@rho = @rho.to_f
		@alpha = @alpha.to_f
		@beta = @beta.to_f
		@initial_trail_density = @initial_trail_density.to_f
		@q = @q.to_f
		self
	end
end