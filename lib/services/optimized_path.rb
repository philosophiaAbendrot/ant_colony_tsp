# frozen_string_literal: true

class OptimizedPath
  attr_reader :shortest_path_length, :shortest_path_vertices,
              :shortest_path_edges, :iteration_path_lengths

  def initialize(ants:, num_iterations:, num_vertices:,
                 include_path_length_vs_iteration: false)
    @num_iterations                   = num_iterations
    @ants                             = ants
    @global_shortest_path_length      = Float::INFINITY
    @global_shortest_path_vertices    = nil
    @global_shortest_path_edges       = nil
    @num_vertices                     = num_vertices
    @include_path_length_vs_iteration = include_path_length_vs_iteration
    @iteration_path_lengths           = []
    optimize
  end

  private

  def optimize
    @num_iterations.times do
      run_tour
    end
  end

  def run_tour
    scramble_ants
    ant_with_shortest_path = survey_ant_paths
    lay_pheromones(ant_with_shortest_path)
    reset_to_original_position
    update_global_shortest_trail
    update_path_length_goal_seeking_history if @include_path_length_vs_iteration
  end

  def scramble_ants
    @ants.each do |ant|
      completed = true
      (@num_vertices - 1).times do
        moved = ant.move_to_next_vertex
        next if moved

        completed = false
        break
      end
      ant.move_to_start if completed
    end
  end

  def survey_ant_paths
    reset_path_info

    @ants.each do |ant|
      # If ant path is shorter than the currently shortest path and ant completed a full tour.
      path_length = ant.find_path_length

      unless path_length < shortest_path_length &&
             ant.visited_edge_ids.length == @num_vertices
        next
      end

      update_shortest_trail(ant)
    end

    @ant_with_shortest_path
  end

  def reset_path_info
    @ant_with_shortest_path  = nil
    @shortest_path_edges     = nil
    @shortest_path_length    = Float::INFINITY
    @shortest_path_vertices  = nil
  end

  def update_shortest_trail(ant)
    @ant_with_shortest_path  = ant
    @shortest_path_edges     = ant.visited_edge_ids
    @shortest_path_length    = ant.find_path_length
    @shortest_path_vertices  = ant.visited_vertex_ids
  end

  def update_global_shortest_trail
    return unless @shortest_path_length < @global_shortest_path_length

    @global_shortest_path_length    = @shortest_path_length
    @global_shortest_path_edges     = @shortest_path_edges
    @global_shortest_path_vertices  = @shortest_path_vertices
  end

  def lay_pheromones(ant_with_shortest_path)
    return unless ant_with_shortest_path

    ant_with_shortest_path.lay_pheromones
    Graph::Edge.update_trail_densities
    true
  end

  def reset_to_original_position
    Ant::Ant.reset_to_original_position
  end

  def update_path_length_goal_seeking_history
    @iteration_path_lengths << @shortest_path_length
  end
end
