class PathFinderOutputPresenter
  attr_reader :formatted_hash

  def initialize(path_finder_goal_seek, options = {})
    @path_finder_goal_seek = path_finder_goal_seek
    @formatted_hash = generate_formatted_hash

    if options[:include_path_length_vs_iteration] &&
       @path_finder_goal_seek.iteration_path_lengths
      incorporate_iteration_path_lengths
    end
  end

  private

  def generate_formatted_hash
    {
      vertices:    @path_finder_goal_seek.shortest_path_vertices,
      edges:       @path_finder_goal_seek.shortest_path_edges,
      path_length: @path_finder_goal_seek.shortest_path_length
    }
  end

  def incorporate_iteration_path_lengths
    @formatted_hash.merge!(
      iteration_path_lengths: @path_finder_goal_seek.iteration_path_lengths
    )
  end
end