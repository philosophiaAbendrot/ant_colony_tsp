require 'bundler/setup'
Bundler.require
require_relative "modules/databaseable"
require_relative "modules/rand_gen"
require_relative "ant/ant"
require_relative "ant/vertex_preference_generator"
require_relative "graph/graph"
require_relative "graph/edge"
require_relative "graph/vertex"
require_relative "config"
require_relative "errors"

# External: Main exectuable class for running this project.
#   Accepts edges, vertices, and other parameters.
#   Initializes and configures objects based on inputs.
#   Runs ant colony optimization logic.
#   Exports data.
class AntColonyTsp
	# Internal: Initializes AntColonyTsp class.
	# 
	# edge_inputs - An Array of Hash objects containing information on the
	#   edges in the graph.
	# vertex_inputs - An Array of Hash objects containing information on
	#   vertices in the graph.
	# include_path_length_vs_iteration - A Boolean object which decides
	#   whether data on the length of the trail for each iteration is included
	#   in the output.
	#
	# Examples
	#
	# edge_inputs = [{ id: 2, start_vertex_id: 3, end_vertex_id: 4,
    #                  cost_of_traversal: 44.13 },
    #                { id: 5, start_vertex_id: 9, end_vertex_id: 3,
    #                  cost_of_traversal: 39.52 }]
	# vertex_inputs = [{ x_pos: 5.4, y_pos: -3.2, id: 3 },
	#                  { x_pos: 8.3, y_pos: 6.5, id: 4 },
	#                  { x_pos: -3.5, y_pos: -5.6, id: 9 }]
	#
	# instance = AntColonyTsp.new(edge_inputs: edge_inputs,
	#                  vertex_inputs:vertex_inputs,
	#                  include_path_length_vs_iteration: true)
	#
	# Returns nothing.
	def initialize(edge_inputs:, vertex_inputs:,
								 include_path_length_vs_iteration:)

		@num_vertices = vertex_inputs.length
		@edge_inputs = edge_inputs
		@vertex_inputs = vertex_inputs
		@include_path_length_vs_iteration = include_path_length_vs_iteration

		config = AntColonyTsp.config

		@num_ants = config.num_ants
		@ant_class = config.ant_class
		@graph_class = config.graph_class
		@vertex_class = config.vertex_class
		@edge_class = config.edge_class
		@rand_gen = config.rand_gen
		@num_iterations = config.num_iterations

		# Pass configuration to model classes.
		@edge_class.set_config(config)
		@graph_class.set_config(config)
		@ant_class.set_config(config)

		nil
	end

	# Internal: Gets Config object associated with class.
	#
	# Returns Config object associated with class. If there is no associated
	#   Config object, it creates a new one.
	def self.config
		@@config ||= Config.new
		@@config
	end

	# External: Exposes Config object, allowing user to configure it using a
	#   block.
	#
	# &block - A block used to update the Config object.
	#
	# Examples
	#
	#   AntColonyTsp.configure do |config|
	#     config.num_ants = 55
	#   end
	#
	# Returns updated Config object.
	def self.configure(&block)
		block.call(self.config)
		# Format the configuration updates.
		self.config.process_configs
	end

	# External: Main entry method for this project. Takes in inputs for
	#   vertices, edges, and other options for output. Runs the ant colony
	#   optimization algorithm and returns the shortest path.
	#
	# edge_inputs - An Array of Hash objects containing information on the
	#   edges in the graph.
	# vertex_inputs - An Array of Hash objects containing information on
	#   vertices in the graph.
	# include_path_length_vs_iteration - A Boolean object which decides
	#   whether data on the length of the trail for each iteration is included
	#   in the output.
	#
	# Examples
	#   edge_inputs = [{ id: 2, start_vertex_id: 3, end_vertex_id: 4,
    #                  cost_of_traversal: 44.13 },
    #                  { id: 5, start_vertex_id: 9, end_vertex_id: 3,
    #                  cost_of_traversal: 39.52 }]
	#   vertex_inputs = [{ x_pos: 5.4, y_pos: -3.2, id: 3 },
	#                    { x_pos: 8.3, y_pos: 6.5, id: 4 },
	#                    { x_pos: -3.5, y_pos: -5.6, id: 9 }]
	#
	#   AntColonyTsp.execute(edge_inputs: edge_inputs,
	#                        vertex_inputs: vertex_inputs,
	#                        include_path_length_vs_iteration: true)
 	# 
 	# Returns a Hash object with the following key-value pairs:
 	#   vertices - An Array of type Integer holding the ids of the vertices
 	#     in order visited.
 	#   edges - An Array of type Integer holding the ids of the edges in order
 	#     visited.
 	#   iteration_path_lengths - An Array of type Float which holds the path
 	#     lengths of the shortest trail found on successive iterations
 	#     starting with the first iteration. Only included if
 	#     'include_path_length_vs_iteration' option is marked true in
 	#     'execute' method.
	def self.execute(edge_inputs:, vertex_inputs:,
									 include_path_length_vs_iteration: false)
		edge_inputs = edge_inputs.map { |el| symbolize_keys(el) }
		vertex_inputs = vertex_inputs.map { |el| symbolize_keys(el) }

		new(edge_inputs: edge_inputs, vertex_inputs: vertex_inputs,
				include_path_length_vs_iteration: include_path_length_vs_iteration).execute
	end

	# Internal: Takes in inputs for vertices, edges, and other options for
	#   output. Runs the ant colony optimization algorithm and returns the
	#   shortest path.
	#
	# Returns a Hash object with the following key-value pairs:
 	#   vertices - An Array of type Integer holding the ids of the vertices
 	#     in order visited.
 	#   edges - An Array of type Integer holding the ids of the edges in order
 	#     visited.
 	#   iteration_path_lengths - An Array of type Float which holds the path
 	#     lengths of the shortest trail found on successive iterations
 	#     starting with the first iteration. Only included if
 	#     'include_path_length_vs_iteration' option is marked true in
 	#     'execute' method.
 	# Raises PathNotFoundError if there was a failure to find a trail. This
 	#   may be because the graph has no Hamiltonian path.
	def execute
		# Initialize graph.
		initialize_graph
		# Initialize ants and place them on random vertices.
		initialize_ants
		iteration_count = 0
		global_shortest_path_vertices = nil
		global_shortest_path_edges = nil
		global_shortest_path_length = Float::INFINITY
		iteration_path_lengths = []

		for iteration_count in 0..@num_iterations - 1
			@ant_class.all.each do |ant|
				# Make every ant execute one tour.
				completed = true

				for i in 0..@num_vertices - 2
					moved = ant.move_to_next_vertex

					unless moved
						completed = false
						break
					end
				end

				# Move ant back to start position.
				ant.move_to_start if completed
			end

			# Find ant with shortest path.
			ant_with_shortest_path = nil
			shortest_path_edges = nil
			shortest_path_length = Float::INFINITY
			shortest_path_vertices = nil

			@ant_class.all.each do |ant|
				# If ant path is shorter than the currently shortest path and ant completed a full tour.
				if (path_length = ant.find_path_length) < shortest_path_length && (ant.visited_edge_ids.length == @num_vertices)
					shortest_path_edges = ant.visited_edge_ids
					shortest_path_vertices = ant.visited_vertex_ids
					shortest_path_length = path_length
					ant_with_shortest_path = ant
				end
			end

			# Lay pheromones on the shortest path.
			ant_with_shortest_path.lay_pheromones if ant_with_shortest_path

			# Update trail densities.
			@edge_class.update_trail_densities

			# Reset ants to original positions.
			@ant_class.reset_to_original_position

			# Update global shortest path.
			if shortest_path_length < global_shortest_path_length
				global_shortest_path_length = shortest_path_length
				global_shortest_path_edges = shortest_path_edges
				global_shortest_path_vertices = shortest_path_vertices
			end

			iteration_path_lengths << shortest_path_length if @include_path_length_vs_iteration
		end


		output = { vertices: global_shortest_path_vertices, edges: global_shortest_path_edges, path_length: global_shortest_path_length }

		raise PathNotFoundError.new("Failed to find a tour. The graph may not have a valid path.") if global_shortest_path_length == Float::INFINITY

		output.merge!(iteration_path_lengths: iteration_path_lengths) if @include_path_length_vs_iteration

		# Clear all database records to prevent memory leak with successive calls.
		@ant_class.destroy_all
		@edge_class.destroy_all
		@vertex_class.destroy_all

		output
	end

	private

	# Internal: Converts a given hash to an equivalent hash in which all its
	#   keys are symbols.
	#
	# h - A given Hash object.
	#
	# Returns a version of the given hash object in which all its keys have
	#   been converted to symbols.
	def self.symbolize_keys(h)
		output = {}
		h.each do |k, v|
			output[k.to_sym] = v
		end

		output
	end

	# Internal: Initializes a graph using edge and vertex inputs provided on
	#   invocation of 'execute' method.
	#
	# Returns generated graph object.
	def initialize_graph
		@graph = @graph_class.new(edge_inputs: @edge_inputs, vertex_inputs: @vertex_inputs)
	end

	# Internal: Initializes ants and places them on random vertices.
	#
	# Returns nothing.
	def initialize_ants
		ant_id = 1
		@num_ants.times do
			rand_num = @rand_gen.rand_int(@vertex_class.all.length)
			@ant_class.new(current_vertex_id: @vertex_class.all[rand_num].id, id: ant_id)
			ant_id += 1
		end

		nil
	end
end