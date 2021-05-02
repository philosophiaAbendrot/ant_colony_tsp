require "modules/databaseable"
require "ant"
require "graph/graph"
require "graph/edge"
require "graph/vertex"
require "utils/rand_gen"

class AntColonyTsp
	attr_reader :time
	NUM_ANTS = 20

	def initialize(edges:, vertices:, graph_class:, vertex_class:, edge_class:, ant_class:, rand_gen:)
		@ant_class = ant_class
		@graph_class = graph_class
		@vertex_class = vertex_class
		@edge_class = edge_class
		@rand_gen = rand_gen

		@time = 0
		# initialize graph
		@graph = @graph_class.new(edges: edges, vertices: vertices, vertex_class: @vertex_class, edge_class: @edge_class)

		ant_id = 1

		NUM_ANTS.times do
			rand_num = @rand_gen.rand_int(@ant_class.all.length)
			@ant_class.new(current_vertex_id: rand_num, vertex_class: @vertex_class, id: ant_id)
			ant_id += 1
		end
	end

	def self.execute(edges:, vertices:, graph_class: Graph::Graph, vertex_class: Graph::Vertex, edge_class: Graph::Edge, ant_class: Ant, rand_gen: Utils::RandGen)
		@main_instance = new(edges: edges,
							vertices: vertices,
							graph_class: graph_class,
							vertex_class: vertex_class,
							edge_class: edge_class,
							ant_class: ant_class,
							rand_gen: rand_gen)
	end
end