# update UML
# 'x_coordinate' to 'x_pos'
# 'y_coordinate' to 'y_pos'

class Ant
	extend Databaseable

	attr_reader :visited_vertex_ids, :x_pos, :y_pos, :current_vertex_id, :visited_edge_ids

	def initialize(start_vertex:, )
		@current_vertex_id = start_vertex.id
		@visited_edge_ids = []
		@visited_vertex_ids = []
		@x_pos = start_vertex.x_pos
		@y_pos = start_vertex.y_pos
	end
end
