# frozen_string_literal: true

class AntInitializerService
  def initialize(ant_class:, num_ants:, vertices:, rand_gen:)
    @ant_class = ant_class
    @num_ants = num_ants
    @vertices = vertices
    @rand_gen = rand_gen
  end

  def execute
    ants = instantiate_ants
    ants.each { |ant| place_ant(ant) }
    true
  end

  private

  def place_ant(ant)
    ant.current_vertex_id = @vertices[@rand_gen.rand_int(@vertices.length)].id
  end

  def instantiate_ants
    (1..@num_ants).map do |id|
      @ant_class.new(id: id)
    end
  end
end
