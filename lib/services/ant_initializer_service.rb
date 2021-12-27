# frozen_string_literal: true

class AntInitializerService
  def initialize(ant_class:, num_ants:, vertices:, rand_gen:)
    @ant_class = ant_class
    @num_ants = num_ants
    @vertices = vertices
    @rand_gen = rand_gen
  end

  def execute
    instantiate_ants
    true
  end

  private

  def start_vertex_id
    rand_num = @rand_gen.rand_int(@vertices.length)
    @vertices[rand_num].id
  end

  def instantiate_ants
    (1..@num_ants).map do |id|
      @ant_class.new(id: id, current_vertex_id: start_vertex_id)
    end
  end
end
