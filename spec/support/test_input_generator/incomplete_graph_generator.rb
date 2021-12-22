module TestInputGenerator
  class IncompleteGraphGenerator < BaseGraphGenerator
    def initialize(num_edges:, num_vertices:, vertices_degree:, constant_difficulty: true)
      @num_edges = num_edges
      @num_vertices = num_vertices
      @constant_difficulty = constant_difficulty
      @vertices_degree = vertices_degree
    end

    private

    def generate_edge_inputs(vertex_outputs)
      edge_outputs = []
      vertex_output_ids = vertex_outputs.map { |el| el[:id] }

      # connect each vertex with the top 5 closest vertices
      edge_id = 0

      vertex_outputs.each do |vertex_output|
        vertex_id = vertex_output[:id]
        second_vertex_id = 0

        vertex_distances = @adj_mat[vertex_id].map do |dist|
          result = [second_vertex_id, dist]
          second_vertex_id += 1
          result
        end

        vertex_distances.delete_at(vertex_id)

        closest_vertices = vertex_distances.sort_by { |el| el[1] }[0..@vertices_degree - 1]

        closest_vertices.each do |second_vertex_id, dist|
          difficulty_1 = @constant_difficulty ? 1 : Math.exp(rand - 0.5)
          difficulty_2 = @constant_difficulty ? 1 : Math.exp(rand - 0.5)

          edge_outputs << { id: edge_id, start_vertex_id: vertex_id, end_vertex_id: second_vertex_id,
                            cost_of_traversal: dist * difficulty_1 }
          edge_outputs << { id: edge_id + 1, start_vertex_id: second_vertex_id, end_vertex_id: vertex_id,
                            cost_of_traversal: dist * difficulty_2 }
          edge_id += 2
        end
      end

      edge_outputs
    end
  end
end
