require 'json'
require_relative "modules/databaseable"
require_relative "ant/ant"
require_relative "ant/vertex_preference_generator"
require_relative "graph/graph"
require_relative "graph/edge"
require_relative "graph/vertex"
require_relative "utils/rand_gen"

class AntColonyTsp
	attr_reader :time
	DEFAULT_NUM_ANTS = 20
	DEFAULT_NUM_ITERATIONS = 100
	ALPHA_VALUE = 1
	INITIAL_TRAIL_DENSITY = 0.3
	BETA_VALUE = 1
	Q = 100
	RHO = 0.5

	def initialize(edge_inputs:, vertex_inputs:, graph_class:, vertex_class:, edge_class:, ant_class:, rand_gen:, num_iterations:, num_ants:)
		@ant_class = ant_class
		@graph_class = graph_class
		@vertex_class = vertex_class
		@edge_class = edge_class
		@rand_gen = rand_gen
		@num_ants = num_ants
		@num_iterations = num_iterations
		@num_vertices = vertex_inputs.length
		@initial_trail_density = INITIAL_TRAIL_DENSITY
		@edge_inputs = edge_inputs
		@vertex_inputs = vertex_inputs

		@time = 0

		true
	end

	def self.execute(edge_inputs:, vertex_inputs:,
									 graph_class: Graph::Graph,
									 vertex_class: Graph::Vertex,
									 edge_class: Graph::Edge,
									 ant_class: Ant::Ant,
									 rand_gen: Utils::RandGen,
									 num_ants: DEFAULT_NUM_ANTS,
									 num_iterations: DEFAULT_NUM_ITERATIONS)
		new(edge_inputs: edge_inputs,
				vertex_inputs: vertex_inputs,
				graph_class: graph_class,
				vertex_class: vertex_class,
				edge_class: edge_class,
				ant_class: ant_class,
				rand_gen: rand_gen,
				num_ants: num_ants,
				num_iterations: num_iterations).execute
	end

	def execute
		# initialize graph
		initialize_graph
		# initialize ants and place them on random vertices
		initialize_ants

		@ant_class.all.each do |ant|
			# make every ant execute one tour
			for i in 0..@num_vertices - 2
				break unless ant.move_to_next_vertex
			end
		end

		# find ant with shortest path
		ant_with_shortest_path = nil
		shortest_path = Float::INFINITY

		@ant_class.all.each do |ant|
			if (path_length = ant.find_path_length) < shortest_path
				shortest_path = path_length
				ant_with_shortest_path = ant
			end
		end

		# lay pheromones on the shortest path
		ant_with_shortest_path.lay_pheromones

		# update trail densities
		@edge_class.update_trail_densities

		puts "edge trail densities:"
		@edge_class.all.each do |edge|
			puts "#{edge.id} || #{edge.cost_of_traversal} || #{edge.trail_density}"
		end

		true
	end

	def self.drive_test
		start_time = Time.now
		edges_file = File.read(__dir__ + "/utils/test_data/test_edge_inputs.json")
		vertices_file = File.read(__dir__ + "/utils/test_data/test_vertex_inputs.json")
		edge_inputs = JSON.parse(edges_file)
		vertex_inputs = JSON.parse(vertices_file)
		end_time = Time.now
		puts "reading and parsing: #{(end_time - start_time) * 1_000} ms"

		# convert edges and vertices keys to symbols
		start_time = Time.now
		edge_inputs = edge_inputs.map { |el| symbolize_keys(el) }
		vertex_inputs = vertex_inputs.map { |el| symbolize_keys(el) }

		execute(edge_inputs: edge_inputs, vertex_inputs: vertex_inputs)
		end_time = Time.now

		# printout results
		Ant::Ant.all.each do |ant|
			puts "#{ant.visited_vertex_ids.length} || #{ant.visited_vertex_ids} || #{ant.find_path_length}"
		end

		puts "execution time: #{(end_time - start_time) * 1_000} ms"
		true
	end

	private

	def self.symbolize_keys(h)
		output = {}
		h.each do |k, v|
			output[k.to_sym] = v
		end

		output
	end

	def initialize_graph
		@graph = @graph_class.new(edge_inputs: @edge_inputs, vertex_inputs: @vertex_inputs, vertex_class: @vertex_class, edge_class: @edge_class, initial_trail_density: @initial_trail_density, trail_persistence: RHO)
	end

	def initialize_ants
		ant_id = 1

		@num_ants.times do
			rand_num = @rand_gen.rand_int(@vertex_class.all.length)
			@ant_class.new(current_vertex_id: @vertex_class.all[rand_num].id, vertex_class: @vertex_class, id: ant_id, edge_class: @edge_class)
			ant_id += 1
		end

		@ant_class.set_pheromone_laying_rate(Q)
	end
end