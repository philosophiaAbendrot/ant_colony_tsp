require 'bundler/setup'
Bundler.require
require_relative "modules/databaseable"
require_relative "ant/ant"
require_relative "ant/vertex_preference_generator"
require_relative "graph/graph"
require_relative "graph/edge"
require_relative "graph/vertex"
require_relative "utils/rand_gen"

class AntColonyTsp
	attr_reader :time
	DEFAULT_NUM_ITERATIONS = 50
	DEFAULT_NUM_ANTS = 30
	ALPHA_VALUE = 1
	INITIAL_TRAIL_DENSITY = 0.05
	BETA_VALUE = 1
	Q = 100
	RHO = 0.8

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
		edge_inputs = edge_inputs.map { |el| symbolize_keys(el) }
		vertex_inputs = vertex_inputs.map { |el| symbolize_keys(el) }
	
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
		iteration_count = 0
		global_shortest_path_vertices = nil
		global_shortest_path_edges = nil
		global_shortest_path_length = Float::INFINITY

		for iteration_count in 0..@num_iterations - 1
			@ant_class.all.each do |ant|
				# make every ant execute one tour
				for i in 0..@num_vertices - 2
					break unless ant.move_to_next_vertex
				end
			end

			# find ant with shortest path
			ant_with_shortest_path = nil
			shortest_path_edges = nil
			shortest_path_length = Float::INFINITY
			shortest_path_vertices = nil

			@ant_class.all.each do |ant|
				if (path_length = ant.find_path_length) < shortest_path_length
					shortest_path_edges = ant.visited_edge_ids
					shortest_path_vertices = ant.visited_vertex_ids
					shortest_path_length = path_length
					ant_with_shortest_path = ant
				end
			end

			# lay pheromones on the shortest path
			ant_with_shortest_path.lay_pheromones

			# update trail densities
			@edge_class.update_trail_densities

			# reset ants to original positions
			@ant_class.reset_to_original_position

			# update global shortest path
			if shortest_path_length < global_shortest_path_length
				global_shortest_path_length = shortest_path_length
				global_shortest_path_edges = shortest_path_edges
				global_shortest_path_vertices = shortest_path_vertices
			end

			edges_data = {}

			@edge_class.all.each do |edge|
				edges_data[edge.id] = { start_vertex_id: edge.start_vertex_id, end_vertex_id: edge.end_vertex_id,
																cost_of_traversal: edge.cost_of_traversal, trail_density: edge.trail_density }
			end


			puts "i:#{iteration_count} shortest path length = #{shortest_path_length}"
		end

		{ vertices: global_shortest_path_vertices, edges: global_shortest_path_edges, path_length: global_shortest_path_length, edges_data: edges_data }
	end

	def self.drive_test
		start_time = Time.now
		edges_file_path = File.expand_path("../data/constant_difficulty/test_edge_inputs.json", __dir__)
		vertices_file_path = File.expand_path("../data/constant_difficulty/test_vertex_inputs.json", __dir__)
		edges_file = File.read(edges_file_path)
		vertices_file = File.read(vertices_file_path)
		edge_inputs = JSON.parse(edges_file)
		vertex_inputs = JSON.parse(vertices_file)
		end_time = Time.now
		puts "reading and parsing: #{(end_time - start_time) * 1_000} ms"

		# convert edges and vertices keys to symbols
		start_time = Time.now
		result = execute(edge_inputs: edge_inputs, vertex_inputs: vertex_inputs)

		puts "shortest path edges = #{result[:edges]}"
		puts "shortest path vertices = #{result[:vertices]}"
		puts "shortest path length = #{result[:path_length]}"

		end_time = Time.now

		# printout results
		# Ant::Ant.all.each do |ant|
		# 	puts "#{ant.visited_vertex_ids.length} || #{ant.visited_vertex_ids} || #{ant.find_path_length}"
		# end

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