# frozen_string_literal: true

# Internal: Module which contains models relating to the graph which is the
#   composition of the edges and the vertices which are supplied as an input.
module Graph
  # Internal: Class which represents a graph.
  class Graph
    # Internal: Initialize a graph.
    #
    # edge_inputs - An array of Hash objects which represents edges.ha
    #   The hashes hold values for the following keys:
    #     id - the Integer id of the edge.
    #     start_vertex_id - the Integer id of the vertex the edge starts on.
    #     end_vertex_id - the Integer id of the vertex the edge ends on.
    #     cost_of_traversal - the Float cost of traversing the edge.
    # vertex_inputs - An array of Hash objects which represents the
    #   vertices. The hashes hold values for the following keys:
    #     id - the Integer id of the vertex.
    #     x_pos - the Float x position of the vertex.
    #     y_pos - the Float y position of the vertex.
    #
    # Examples
    #
    #   edge_inputs = [{ id: 5, start_vertex_id: 3, end_vertex_id: 9,
    #     cost_of_traversal: 1.79 },
    #     { id: 9, start_vertex_id: 3, end_vertex_id: 4,
    #     cost_of_traversal: 39.5 }]
    #   vertex_inputs = [{ id: 5, x_pos: 8.3, y_pos: -95.1 },
    #                    { id: 8, x_pos: -6.49, y_pos: 7.76 }]
    # Graph.new(edge_inputs, vertex_inputs)
    #
    # Returns nothing.
    def initialize(edge_inputs:, vertex_inputs:)
      initialize_edges(edge_inputs)
      initialize_vertices(vertex_inputs)
      connect_edges_with_vertices

      nil
    end

    # Internal: Sets values of configurable class variables.
    #
    # config - Config instance used to configure various classes.
    #
    # Returns nothing.
    def self.set_config(config)
      @@vertex_class = config.vertex_class
      @@edge_class = config.edge_class
      # The pheromone density that all edges have initially.
      @@initial_trail_density = config.initial_trail_density
      @@rho = config.rho

      nil
    end

    private

    # Internal: Initializes edges using an input object which is a nested
    #   array containing edge parameters. The arrays elements are, in order:
    #     id - The Integer id of the edge.
    #     start_vertex_id - The Integer id of the start vertex.
    #     end_vertex_id - The Integer id of the end vertex.
    #     cost_of_traversal - The Float cost of traversing the edge.
    #
    # Examples
    #
    #   initialize_edges([[1, 3, 4, 5.3], [3, 6, 2, 11.5], [2, 6, 9, 4.3]])
    #
    # Returns nothing.
    # Raises ArgumentError if 'edge_inputs' field is not an array.
    def initialize_edges(edge_inputs)
      raise ArgumentError, 'Edges input is not an array' unless edge_inputs.is_a?(Array)

      edge_inputs.each do |edge_input|
        if edge_input.is_a?(Hash)
          @@edge_class.new(edge_input)
        else
          raise ArgumentError, 'Edge input is not in hash format'
        end
      end

      # set initial trail densities
      @@edge_class.initialize_trail_densities

      nil
    end

    # Internal: Initializes vertices using an input object which is a
    #   nested array containing vertex parameters. The elements are,
    #   in order:
    #     id - The Integer id of the vertex.
    #     x_pos: The Float x position of the vertex.
    #     y_pos: The Float y position of the vertex.
    #
    # Examples
    #
    #   initialize_vertices([[5, 6.3, 6.6], [4, 2.6, 8.7]])
    #
    # Returns nothing.
    # Raises ArgumentError if 'vertex_inputs' field is not an array.
    def initialize_vertices(vertex_inputs)
      raise ArgumentError, 'Vertices input is not an array' unless vertex_inputs.is_a?(Array)

      vertex_inputs.each do |vertex_input|
        if vertex_input.is_a?(Hash)
          @@vertex_class.new(vertex_input)
        else
          raise ArgumentError, 'Vertex input is not in hash format'
        end
      end

      nil
    end

    # Internal: Connects vertex and edge objects together based on the
    #   'start_vertex_id' and 'end_vertex_id' values of edges.
    #
    # Returns nothing.
    def connect_edges_with_vertices
      @@edge_class.all.each do |edge|
        edge.start_vertex.outgoing_edge_ids << edge.id
      end

      nil
    end
  end
end
