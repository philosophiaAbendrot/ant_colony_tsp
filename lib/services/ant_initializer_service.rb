# frozen_string_literal: true

class AntInitializerService
  def initialize(ants, vertices)
    @ants = ants
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
    (1..@ants.length).map do |id|
      Ant::Ant.new(id: id, current_vertex_id: start_vertex_id)
    end
  end
end
