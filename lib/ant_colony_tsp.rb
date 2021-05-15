require 'bundler/setup'
Bundler.require
require_relative "modules/databaseable"
require_relative "ant/ant"
require_relative "ant/vertex_preference_generator"
require_relative "graph/graph"
require_relative "graph/edge"
require_relative "graph/vertex"
require_relative "utils/rand_gen"
require_relative "config"

class AntColonyTsp
	attr_reader :time

	def initialize(edge_inputs:, vertex_inputs:,
								 include_edges_data:,
								 include_path_length_vs_iteration:)

		@num_vertices = vertex_inputs.length
		@edge_inputs = edge_inputs
		@vertex_inputs = vertex_inputs
		@include_edges_data = include_edges_data
		@include_path_length_vs_iteration = include_path_length_vs_iteration
		@time = 0

		config = AntColonyTsp.config

		@num_ants = config.num_ants
		@ant_class = config.ant_class
		@graph_class = config.graph_class
		@vertex_class = config.vertex_class
		@edge_class = config.edge_class
		@rand_gen = config.rand_gen
		@num_iterations = config.num_iterations

		# pass configuration to model classes
		@edge_class.set_config(config)
		@graph_class.set_config(config)
		@ant_class.set_config(config)

		true
	end

	def self.config
		@@config ||= Config.new
		@@config
	end

	def self.configure(&block)
		block.call(self.config)
		self.config.process_configs
	end

	def self.execute(edge_inputs:, vertex_inputs:,
									 include_edges_data: false,
									 include_path_length_vs_iteration: false)
		edge_inputs = edge_inputs.map { |el| symbolize_keys(el) }
		vertex_inputs = vertex_inputs.map { |el| symbolize_keys(el) }

		new(edge_inputs: edge_inputs, vertex_inputs: vertex_inputs, include_edges_data: include_edges_data,
				include_path_length_vs_iteration: include_path_length_vs_iteration).execute
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
		iteration_path_lengths = []

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

			iteration_path_lengths << shortest_path_length if @include_path_length_vs_iteration
		end

		output = { vertices: global_shortest_path_vertices, edges: global_shortest_path_edges, path_length: global_shortest_path_length }

		if @include_edges_data
			edges_data = {}

			@edge_class.all.each do |edge|
				edges_data[edge.id] = { start_vertex_id: edge.start_vertex_id, end_vertex_id: edge.end_vertex_id,
																cost_of_traversal: edge.cost_of_traversal, trail_density: edge.trail_density }
			end

			output.merge!(edges_data: edges_data)
		end

		output.merge!(iteration_path_lengths: iteration_path_lengths) if @include_path_length_vs_iteration
		output
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
		@graph = @graph_class.new(edge_inputs: @edge_inputs, vertex_inputs: @vertex_inputs)
	end

	def initialize_ants
		ant_id = 1
		@num_ants.times do
			rand_num = @rand_gen.rand_int(@vertex_class.all.length)
			@ant_class.new(current_vertex_id: @vertex_class.all[rand_num].id, id: ant_id)
			ant_id += 1
		end
	end
end