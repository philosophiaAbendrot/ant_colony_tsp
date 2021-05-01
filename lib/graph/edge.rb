module Graph
	class Edge
		extend Databaseable

		attr_accessor :trail_density

		attr_reader :id, :start_vertex_id, :end_vertex_id, :cost_of_traversal

		def initialize(id: , cost_of_traversal:, start_vertex_id:, end_vertex_id:)		
			@id = id
			@cost_of_traversal = cost_of_traversal
			@start_vertex_id = start_vertex_id
			@end_vertex_id = end_vertex_id
			@trail_density = 0
		end

		def self.initialize_trail_densities(set_value)
			# set trail density to 0 for all edges
			instances.values.each do |edge|
				edge.trail_density = set_value
			end
		end
	end
end