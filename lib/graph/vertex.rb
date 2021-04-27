# need to add outgoing_edge_ids and incoming_edge_ids to UML
# update UML
# 'x_coordinate' to 'x_pos'
# 'y_coordinate' to 'y_pos'

module Graph
	class Vertex
		extend Databaseable

		attr_reader :x_pos, :y_pos, :id, :edge_ids, :outgoing_edge_ids, :incoming_edge_ids

		def initialize(x_pos:, y_pos:, id:)
			@x_pos = x_pos
			@y_pos = y_pos
			@outgoing_edge_ids = []
			@incoming_edge_ids = []
		end
	end
end