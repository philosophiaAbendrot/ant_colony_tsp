# frozen_string_literal: true

class AntInitializerService
  def initialize(ant_class:, num_ants:, vertices:)
    @ant_class = ant_class
    @num_ants = num_ants
    @vertices = vertices
  end

  def execute
    instantiate_ants
    true
  end

  private

  def start_vertex_id
    @vertices[rand(@vertices.length)].id
  end

  def instantiate_ants
    (1..@num_ants).map do |id|
      @ant_class.new(id: id, current_vertex_id: start_vertex_id)
    end
  end
end
