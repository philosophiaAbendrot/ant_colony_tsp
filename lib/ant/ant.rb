# frozen_string_literal: true

# Internal: Module which contains the Ant class for traversing the graph and
#   its supporting logic.
module Ant
  # Internal: Class used for traversing graph and marking it with
  #   pheromones.
  class Ant
    # Logic which stores instances and allow them to be searched.
    extend Databaseable

    # Internal: Gets/sets the id of the vertex the ant is currently on.
    attr_accessor :current_vertex_id
    #
    # Internal: Gets/sets the list of ids of the vertices that the ant has
    #   visited.
    attr_accessor :visited_vertex_ids
    #
    # Internal: Gets/sets the list of ids of the edges that the ant has
    #   visited.
    attr_accessor :visited_edge_ids

    # Internal: Initialize ant
    #
    # current_vertex_id: The Integer id of the vertex that the ant starts
    #   on.
    # id - The Integer id of the ant.
    def initialize(id:, current_vertex_id: nil)
      @id = id
      @current_vertex_id = current_vertex_id
      @visited_edge_ids = []
      @visited_vertex_ids = [current_vertex_id]
    end

    class << self
      attr_reader :vertex_class, :edge_class, :rand_gen
      # The amount of pheromone which is deposited by the ant which
      #   finds the shortest trail. This amount of pheromone is divided
      #   evenly among all the edges of the trail.
      attr_reader :q
      # alpha - coefficient controlling the importance of pheromone strength in
      #   influencing choice of next vertex.
      attr_reader :alpha
      # beta - coefficient controlling the importance of proximity in
      #   influencing choice of next vertex.
      attr_reader :beta

      # Internal: Sets values of configurable class variables.
      #
      # config - Object used to configure various classes.
      #
      # Returns nothing.
      def set_config(config)
        @vertex_class = config.vertex_class
        @edge_class = config.edge_class
        @rand_gen = config.rand_gen
        @q = config.q
        @alpha = config.alpha
        @beta = config.beta

        nil
      end

      # Internal: Returns all ants to their original vertices.
      #
      # Returns nothing.
      def reset_to_original_position
        all.each do |ant|
          first_vertex_id = ant.visited_vertex_ids[0]
          ant.visited_vertex_ids = [first_vertex_id]
          ant.visited_edge_ids = []
          ant.current_vertex_id = first_vertex_id
        end

        nil
      end
    end

    # Internal: Return the vertex that the ant object is currently on.
    #
    # Returns the vertex object that the ant is currently on.
    def current_vertex
      self.class.vertex_class.find(@current_vertex_id)
    end

    # Internal: Returns the x_pos of the vertex that the ant is currently
    #   on.
    #
    # Returns the x_pos of the vertex that the ant is currently on.
    def x_pos
      current_vertex.x_pos
    end

    # Internal: Returns the y_pos of the vertex that the ant is currently
    #   on.
    #
    # Returns the x_pos of the vertex that the ant is currently on.
    def y_pos
      current_vertex.y_pos
    end

    # Internal: Makes the ant select a vertex to move to and move to it.
    #
    # Returns true if the ant successfully moved to the next vertex.
    #   Returns false if the ant has reached a dead end and cannot
    #   move. This can occur if there are no outgoing edges to vertice
    #   that haven't been visited, or if all vertices have been visited.
    def move_to_next_vertex
      selected_vertex_id, selected_edge_id = find_next_edge_and_vertex
      return false if selected_vertex_id.nil?

      move_to_vertex_through_edge(selected_vertex_id, selected_edge_id)
      true
    end

    # Internal: Returns an ant to the vertex that it started on if
    #   that vertex is directly connected to the current vertex.
    #   This method is used to return the ant to the starting
    #   vertex after it has visited every vertex.
    #
    # Returns true if the ant is successfully moved to its starting
    #   vertex and false otherwise.
    def move_to_start
      start_vertex_id = @visited_vertex_ids[0]
      selected_edge_id = find_edge_to_start_vertex(start_vertex_id)
      return false if selected_edge_id.nil?

      move_to_vertex_through_edge(start_vertex_id, selected_edge_id)
      true
    end

    # Internal: Calculates and returns the total path length of the path
    #   that the ant travelled starting from the start vertex.
    #
    # Returns the total travel length.
    def find_path_length
      @visited_edge_ids.map { |el| self.class.edge_class.find(el).cost_of_traversal }.sum
    end

    # Internal: Adds pheremones to all the edges that the ant travelled
    #   through on its path.
    def lay_pheromones
      trail_density = self.class.q / find_path_length

      visited_edges = @visited_edge_ids.map do |edge_id|
        self.class.edge_class.find(edge_id)
      end

      visited_edges.each do |edge|
        edge.add_pheromones(trail_density)
      end

      nil
    end

    private

    def evaluate_preferences
      VertexPreferences.new(
        outgoing_edges: outgoing_edges,
        visited_vertex_ids: @visited_vertex_ids.dup,
        alpha: self.class.alpha,
        beta: self.class.beta,
        rand_gen: self.class.rand_gen
      )
    end

    def find_connecting_edge(selected_vertex_id)
      outgoing_edges.select do |edge|
        edge.end_vertex_id == selected_vertex_id
      end.first.id
    end

    def find_next_edge_and_vertex
      cumulative_preferences = evaluate_preferences
      return [nil, nil] if cumulative_preferences.empty?

      selected_vertex_id = cumulative_preferences.select_rand_vertex
      selected_edge_id = find_connecting_edge(selected_vertex_id)
      [selected_vertex_id, selected_edge_id]
    end

    def move_to_vertex_through_edge(selected_vertex_id, selected_edge_id)
      @current_vertex_id = selected_vertex_id
      @visited_vertex_ids << selected_vertex_id
      @visited_edge_ids << selected_edge_id

      nil
    end

    def outgoing_edges
      current_vertex.outgoing_edge_ids.map do |edge_id|
        self.class.edge_class.find(edge_id)
      end
    end

    def find_edge_to_start_vertex(start_vertex_id)
      prospective_edges = outgoing_edges.select do |edge|
        edge.end_vertex_id == start_vertex_id
      end

      prospective_edges.first&.id
    end
  end
end
