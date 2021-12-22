# frozen_string_literal: true

module TestInputGenerator
  class BaseGraphGenerator
    def execute
      vertex_outputs = generate_vertex_inputs
      populate_adjacency_matrix(vertex_outputs)
      edge_outputs = generate_edge_inputs(vertex_outputs)

      [vertex_outputs, edge_outputs]
    end

    protected

    def populate_adjacency_matrix(vertex_outputs)
      @adj_mat = Array.new(@num_vertices) { Array.new(@num_vertices) { -1 } }

      vertex_outputs.each do |vertex_a|
        vertex_outputs.each do |vertex_b|
          next unless vertex_a[:id] != vertex_b[:id]

          # calculate distance between vertices
          dist = Math.sqrt((vertex_b[:x_pos] - vertex_a[:x_pos])**2 + (vertex_b[:y_pos] - vertex_a[:y_pos])**2)
          @adj_mat[vertex_a[:id]][vertex_b[:id]] = dist
          @adj_mat[vertex_b[:id]][vertex_a[:id]] = dist
        end
      end
    end

    def generate_vertex_inputs
      vertex_outputs = []

      (0..@num_vertices - 1).each do |i|
        vertex_outputs << { id: i, x_pos: (40 * rand - 20).round(2), y_pos: (40 * rand - 20).round(2) }
      end

      vertex_outputs
    end

    def duplicate_edge_exists?(vertex_a_id, vertex_b_id)
      @adj_mat[vertex_a_id][vertex_b_id] != -1
    end
  end
end
