# frozen_string_literal: true

# Internal: Module which contains Ant class for traversing graph and its
#   supporting logic.
module Ant
  # Internal: Class used for surveying connected vertices and generating
  #   preference values for each.
  #
  # outgoing_edges - An Array of type Integer holding the list of ids of
  #   edges which the and has travelled through.
  # visited_vertex_ids - An Array of type Integer holding the list of ids of
  #   vertices which the ant has visited.
  # alpha - A Float coefficient controlling the importance of pheromone
  #   strength in influencing choice of next vertex.
  # beta - A Float coefficient controlling the importance of proximity in
  #   influencing choice of next vertex.
  #
  # Returns the mapping of preferences as a 2d array in the
  class VertexPreferences
    attr_reader :preference_mapping

    def initialize(outgoing_edges:, visited_vertex_ids:, alpha:, beta:,
                   rand_gen:)
      total_preference = 0
      preference_mapping = []
      @rand_gen = rand_gen

      total_preference, preference_mapping = compute_preference_mapping(
        prospective_edges(outgoing_edges, visited_vertex_ids),
        alpha,
        beta
      )

      # Normalize the mapping
      @preference_mapping = normalize_mapping(preference_mapping, total_preference)
    end

    def empty?
      @preference_mapping.empty?
    end

    def select_rand_vertex
      rand_num = @rand_gen.rand_float
      selected_vertex_id = nil

      (0..@preference_mapping.length - 1).each do |i|
        vertex_id, cumulative_probability = @preference_mapping[i]

        if cumulative_probability >= rand_num
          selected_vertex_id = vertex_id
          break
        end
      end

      selected_vertex_id
    end

    private

    def prospective_edges(outgoing_edges, visited_vertex_ids)
      outgoing_edges.select do |edge|
        !visited_vertex_ids.include?(edge.end_vertex_id)
      end
    end

    def compute_preference_mapping(prospective_edges, alpha, beta)
      total_preference = 0
      preference_mapping = []

      prospective_edges.each do |edge|
        product = edge.trail_density**alpha * (1 / edge.cost_of_traversal)**beta
        total_preference += product
        preference_mapping << [edge.end_vertex_id, total_preference]
      end

      [total_preference, preference_mapping]
    end

    def normalize_mapping(preference_mapping, total_preference)
      preference_mapping.map { |el| [el[0], el[1] / total_preference] }
    end
  end
end
