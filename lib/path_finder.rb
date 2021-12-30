# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
require_relative 'modules/databaseable'
require_relative 'modules/rand_gen'
require_relative 'ant/ant'
require_relative 'ant/vertex_preferences'
require_relative 'graph/graph'
require_relative 'graph/edge'
require_relative 'graph/vertex'
require_relative 'services/ant_initializer_service'
require_relative 'services/optimized_path'
require_relative 'services/path_finder_output_presenter'
require_relative 'config'
require_relative 'errors'

# Public: Main exectuable class for running this project.
#   Accepts edges, vertices, and other parameters.
#   Initializes and configures objects based on inputs.
#   Runs ant colony optimization logic.
#   Exports data.
class PathFinder
  def initialize(edge_inputs:, vertex_inputs:,
                 include_path_length_vs_iteration:)

    @num_vertices = vertex_inputs.length
    @edge_inputs = edge_inputs
    @vertex_inputs = vertex_inputs
    @include_path_length_vs_iteration = include_path_length_vs_iteration

    config = self.class.config

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
  end

  # Internal: Gets Config object associated with class.
  #
  # Returns Config object associated with class. If there is no associated
  #   Config object, it creates a new one.
  def self.config
    @@config ||= Config.new
    @@config
  end

  # Public: Exposes Config object, allowing user to configure it using a
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
    block.call(config)
    # Format the configuration updates.
    config.process_configs
  end

  # Public: Main entry method for this project. Takes in inputs for
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
    edge_inputs = edge_inputs.transform_keys!(&:to_sym)
    vertex_inputs = vertex_inputs.transform_keys!(&:to_sym)

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
    initialize_graph
    initialize_ants
    optimized_path = perform_path_optimization

    presenter = PathFinderOutputPresenter.new(
      optimized_path,
      include_path_length_vs_iteration: @include_path_length_vs_iteration
    )

    destroy_graph
    presenter.formatted_hash
  end

  private

  def initialize_graph
    @graph = @graph_class.new(edge_inputs: @edge_inputs, vertex_inputs: @vertex_inputs)
  end

  def initialize_ants
    AntInitializerService.new(
      ant_class: @ant_class,
      vertices: @vertex_class.all,
      num_ants: @num_ants,
      rand_gen: @rand_gen
    ).execute

    nil
  end

  def perform_path_optimization
    optimized_path = OptimizedPath.new(
      ants:                             @ant_class.all,
      num_iterations:                   @num_iterations,
      num_vertices:                     @num_vertices,
      include_path_length_vs_iteration: @include_path_length_vs_iteration)

    if optimized_path.shortest_path_length == Float::INFINITY
      raise PathNotFoundError, 'Failed to find a tour. The graph may not have a valid path.'
    end

    optimized_path
  end

  def destroy_graph
    # Clear all database records to prevent memory leak with successive calls.
    @ant_class.destroy_all
    @edge_class.destroy_all
    @vertex_class.destroy_all
  end
end
