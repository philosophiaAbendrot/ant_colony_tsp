# frozen_string_literal: true

class ExactSolutionFinder
  def initialize(edge_input, vertex_input)
    @vertex_input = vertex_input
    @edge_input = edge_input
  end

  def self.call(edge_input, vertex_input)
    new(vertex_input, edge_input).call
  end

  def call
    # construct an adjacency matrix from the input
    @adj_mat = construct_adj_mat(@edge_input, @vertex_input.length)
    @vertex_table = construct_vertex_table(@vertex_input)

    # dfs logic
    # select random start vertex
    @list_of_orderings = []
    @all_orderings = find_all_orderings(@vertex_input.map { |el| el[:id] })
    min_path_length = Float::INFINITY
    min_path_ordering = nil

    # for each ordering, find the path length
    @all_orderings.each do |ordering|
      path_length = 0
      current_vertex = ordering[0]

      (1..ordering.length - 1).each do |i|
        next_vertex = ordering[i]
        path_length += @adj_mat[current_vertex][next_vertex][:cost_of_traversal]
        current_vertex = next_vertex
      end

      path_length += @adj_mat[current_vertex][ordering[0]][:cost_of_traversal]

      if path_length < min_path_length
        min_path_length = path_length
        min_path_ordering = ordering
      end
    end

    [min_path_length, min_path_ordering]
  end

  private

  def find_all_orderings(vertex_ids)
    all_orderings = []
    stack = [[vertex_ids, []]]

    until stack.empty?
      choices, ordering = stack.pop

      # if choices is empty
      if choices.empty?
        all_orderings.push(ordering)
        next
      end

      choices.each do |vertex_id|
        dup_choices = choices.dup
        dup_choices.delete(vertex_id)
        stack.push([dup_choices, ordering + [vertex_id]])
      end
    end

    all_orderings
  end

  def construct_adj_mat(edge_input, num_vertices)
    adj_mat = Array.new(num_vertices) { Array.new(num_vertices) { nil } }

    edge_input.each do |edge|
      adj_mat[edge[:start_vertex_id]][edge[:end_vertex_id]] = edge
    end

    adj_mat
  end

  def construct_vertex_table(vertex_input)
    vertex_table = {}

    vertex_input.each do |vertex|
      vertex_table[vertex[:id]] =
        { x_pos: vertex[:x_pos], y_pos: vertex[:y_pos], cost_of_traversal: vertex[:cost_of_traversal] }
    end

    vertex_table
  end
end
