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
  class VertexPreferenceGenerator
    def self.execute(outgoing_edges:, visited_vertex_ids:, alpha:, beta:)
      prospective_edges = outgoing_edges.select { |edge| !visited_vertex_ids.include?(edge.end_vertex_id) }
      sum_products = 0
      preference_mapping = []

      prospective_edges.each do |edge|
        product = edge.trail_density**alpha * (1 / edge.cost_of_traversal)**beta
        sum_products += product
        # Store end vertex id and cumulative probability.
        preference_mapping << [edge.end_vertex_id, sum_products]
      end

      # Normalize the mapping.
      preference_mapping.map { |el| [el[0], el[1] / sum_products] }
    end
  end
end
