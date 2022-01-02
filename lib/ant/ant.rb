# frozen_string_literal: true

# Internal: Module which contains the Ant class for traversing the graph and
#   its supporting logic.
module Ant
  # Internal: Class used for traversing graph and marking it with
  #   pheromones.
  class Ant
    # Logic which stores instances and allow them to be searched.
    extend Databaseable

    attr_accessor :current_vertex_id
    attr_accessor :visited_vertex_ids
    attr_accessor :visited_edge_ids

    def initialize(id:, current_vertex_id: nil)
      @id = id
      @current_vertex_id = current_vertex_id
      @visited_edge_ids = []
      @visited_vertex_ids = [current_vertex_id]
    end

    class << self
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

    def current_vertex
      Graph::Vertex.find(@current_vertex_id)
    end

    def x_pos
      current_vertex.x_pos
    end

    def y_pos
      current_vertex.y_pos
    end

    def move_to_next_vertex
      selected_vertex_id, selected_edge_id = find_next_edge_and_vertex
      return false if selected_vertex_id.nil?

      move_to_vertex_through_edge(selected_vertex_id, selected_edge_id)
      true
    end

    def move_to_start
      start_vertex_id = @visited_vertex_ids[0]
      selected_edge_id = find_edge_to_start_vertex(start_vertex_id)
      return false if selected_edge_id.nil?

      move_to_vertex_through_edge(start_vertex_id, selected_edge_id)
      true
    end

    def find_path_length
      @visited_edge_ids.map { |el| Graph::Edge.find(el).cost_of_traversal }.sum
    end

    def lay_pheromones
      trail_density = self.class.q / find_path_length

      visited_edges = @visited_edge_ids.map do |edge_id|
        Graph::Edge.find(edge_id)
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
        beta: self.class.beta
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
        Graph::Edge.find(edge_id)
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
