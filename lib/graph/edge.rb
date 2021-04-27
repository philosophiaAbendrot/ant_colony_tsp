module Graph
	class Edge
		extend Databaseable

		attr_reader :id, :start_vertex_id, :end_vertex_id

		def initialize(id: , cost_of_traversal:, start_vertex_id:, end_vertex_id:)		
			@cost_of_traversal = cost_of_traversal
			@start_vertex = start_vertex
			@end_vertex = end_vertex
			@pheromone_count = 0
		end
	end
end