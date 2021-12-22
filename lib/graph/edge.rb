# frozen_string_literal: true

# Internal: Module which contains models relating to the graph which is the
#   composition of the edges and the vertices which are supplied as an input.
module Graph
  # Internal: Class which represents an edge.
  class Edge
    # Logic which stores instances and allow them to be searched.
    extend Databaseable

    # Internal: Gets/sets the density of the pheromones on the edge.
    attr_accessor :trail_density

    # Internal: Gets/sets the change to the pheremones on the edge in the
    #   current time step.
    attr_accessor :delta_trail_density

    # Internal: Gets the id of the edge.
    attr_reader :id

    # Internal: Gets the id of the vertex which this edge starts at.
    attr_reader :start_vertex_id

    # Internal: Gets the id of the vertex which this edge ends at.
    attr_reader :end_vertex_id

    # Internal: Gets the cost of traversing this edge. This can represent
    #   the physical length of the edge or the time required to traverse
    #   it, or anything else.
    attr_reader :cost_of_traversal

    # Internal: Initialize an edge.
    #
    # id - The id of the edge.
    # cost_of_traversal - The cost of traversal of the edge.
    # start_vertex_id - The id of the vertex that the edge starts at.
    # end_vertex_id  - The id of the vertex that the edge ends at.
    def initialize(id:, cost_of_traversal:, start_vertex_id:, end_vertex_id:)
      @id = id
      @cost_of_traversal = cost_of_traversal.to_f
      @start_vertex_id = start_vertex_id
      @end_vertex_id = end_vertex_id
      @trail_density = 0.0
      @delta_trail_density = 0.0
    end

    # Internal: Sets the pheromone density on all edges to a certain
    #   value.
    def self.initialize_trail_densities
      set_trail_densities(@@initial_trail_density)
    end

    # Internal: Sets values of configurable class variables.
    #
    # config - Object used to configure various classes.
    def self.set_config(config)
      # Sets the vertex class.
      @@vertex_class = config.vertex_class
      # Coefficient which represents how quickly pheromone trails
      #   evaporate.
      @@rho = config.rho
      # Sets the initial pheromone density of all edges.
      @@initial_trail_density = config.initial_trail_density
    end

    # Internal: Sets the pheromone trail density of all edges to the given
    #   value.
    #
    # set_value - The value which the pheromone trail densities of all
    #   edges are set to.
    def self.set_trail_densities(set_value)
      all.each do |edge|
        edge.trail_density = set_value
      end
    end

    # Internal: Updates the pheromone trail densities of all edges for the
    #   next time-step.
    def self.update_trail_densities
      all.each do |edge|
        # The trail density of the next time step is calculated using
        #   the current trail density, the next step's trail density,
        #   and the variable 'rho' which represents how quickly
        #   the pheromone evaporates.
        edge.trail_density = edge.trail_density * @@rho + edge.delta_trail_density
        edge.delta_trail_density = 0.0
      end
    end

    # Internal: Gets the start vertex of the edge.
    #
    # Returns the vertex object which the edge starts on.
    def start_vertex
      @@vertex_class.find(@start_vertex_id)
    end

    # Internal: Gets the end vertex of the edge.
    #
    # Returns the vertex object which the edge ends on.
    def end_vertex
      @@vertex_class.find(@end_vertex_id)
    end

    # Internal: Sets the delta trail density value.
    #
    # delta - The delta_trail_density value is set to this value.
    def add_pheromones(delta)
      @delta_trail_density = delta

      return
    end
  end
end
