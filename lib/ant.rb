# update UML
# 'x_coordinate' to 'x_pos'
# 'y_coordinate' to 'y_pos'

class Ant
	extend Databaseable

	attr_accessor :current_vertex_id
	attr_reader :visited_vertex_ids, :visited_edge_ids

	def initialize(current_vertex_id:, vertex_class:, id:, edge_class:)
		@id = id
		@current_vertex_id = current_vertex_id
		@visited_edge_ids = []
		@visited_vertex_ids = [current_vertex_id]
		@vertex_class = vertex_class
		@edge_class = edge_class
	end

	def current_vertex
		@vertex_class.find(@current_vertex_id)
	end

	def x_pos
		current_vertex.x_pos
	end

	def y_pos
		current_vertex.y_pos
	end

	def move_to_next_vertex
	end
end
