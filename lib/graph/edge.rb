module Graph
	class Edge
		attr_reader :id
		# store edges for find functionality
		@@edges = {}
		@@last_id = 0

		def self.find(id)
			@@edges[id]
		end

		def initialize(cost_of_traversal:, start_vertex:, end_vertex:)		
			@id = @@last_id + 1
			@cost_of_traversal = cost_of_traversal
			@start_vertex = start_vertex
			@end_vertex = end_vertex
			@pheromone_count = 0
			@@edges[@id] = self
		end
	end
end