# need to add outgoing_edge_ids and incoming_edge_ids to UML
# update UML
# 'x_coordinate' to 'x_pos'
# 'y_coordinate' to 'y_pos'

module Graph
	class Vertex
		extend Databaseable

		attr_accessor :outgoing_edge_ids, :incoming_edge_ids

		attr_reader :x_pos, :y_pos, :id

		def initialize(x_pos:, y_pos:, id:)
			@id = id
			@x_pos = x_pos.to_f
			@y_pos = y_pos.to_f
			@outgoing_edge_ids = []
			@incoming_edge_ids = []
		end
	end
end