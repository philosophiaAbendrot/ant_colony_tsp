require 'json'

module TestInputGenerator
  class TestInputGenerator
    def initialize(num_vertices:, num_edges:, complete_graph:, write_to_file:, vertices_degree:, constant_difficulty:)
      @num_vertices = num_vertices
      @num_edges = num_edges

      @write_to_file = write_to_file

      if complete_graph
        @graph_gen_instance = CompleteGraphGenerator.new(num_vertices: num_vertices,
                                                         constant_difficulty: constant_difficulty)
      else
        @graph_gen_instance = IncompleteGraphGenerator.new(num_vertices: num_vertices, num_edges: num_edges,
                                                           vertices_degree: vertices_degree, constant_difficulty: constant_difficulty)
      end
    end

    def self.execute(complete_graph:, num_vertices:, num_edges: nil, write_to_file: true, constant_difficulty: true, vertices_degree: 18)
      start_time = Time.now
      result = new(num_vertices: num_vertices,
                   num_edges: num_edges,
                   complete_graph: complete_graph,
                   write_to_file: write_to_file,
                   constant_difficulty: constant_difficulty,
                   vertices_degree: vertices_degree).execute
      end_time = Time.now
      result
    end

    def execute
      start_time = Time.now
      vertex_outputs, edge_outputs = @graph_gen_instance.execute
      end_time = Time.now

      if @write_to_file
        write_results_to_file(vertex_outputs, edge_outputs)
        true
      else
        [vertex_outputs, edge_outputs]
      end
    end

    private

    def write_results_to_file(vertex_outputs, edge_outputs)
      vertex_input_file_path = File.expand_path('../../../data/constant_difficulty/test_vertex_inputs.json', __dir__)

      File.open(vertex_input_file_path, 'w') do |f|
        f.write('[')

        (0..vertex_outputs.length - 1).each do |i|
          line = vertex_outputs[i]
          f.write(line.to_json)

          f.write(',') if i != vertex_outputs.length - 1
        end

        f.write(']')
      end

      edge_input_file_path = File.expand_path('../../../data/constant_difficulty/test_edge_inputs.json', __dir__)

      File.open(edge_input_file_path, 'w') do |f|
        f.write('[')

        (0..edge_outputs.length - 1).each do |i|
          line = edge_outputs[i]
          f.write(line.to_json)

          f.write(',') if i != edge_outputs.length - 1
        end

        f.write(']')
      end

      true
    end
  end
end
