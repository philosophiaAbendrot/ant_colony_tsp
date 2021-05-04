module Graph
	class Edge
		extend Databaseable

		attr_accessor :trail_density, :delta_trail_density

		attr_reader :id, :start_vertex_id, :end_vertex_id, :cost_of_traversal

		def initialize(id: , cost_of_traversal:, start_vertex_id:, end_vertex_id:, vertex_class:)
			@id = id
			@cost_of_traversal = cost_of_traversal.to_f
			@start_vertex_id = start_vertex_id
			@end_vertex_id = end_vertex_id
			@trail_density = 0.0
			@delta_trail_density = 0.0
			@vertex_class = vertex_class
		end

		def self.set_trail_densities(set_value)
			# set trail density to a set value for all edges
			all.each do |edge|
				edge.trail_density = set_value.to_f
			end
		end

		def self.initialize_delta_trail_densities
			# trail delta trail density to 0 for all edges
			all.each do |edge|
				edge.delta_trail_density = 0.0
			end
		end

		def start_vertex
			@vertex_class.find(@start_vertex_id)
		end

		def end_vertex
			@vertex_class.find(@end_vertex_id)
		end
	end
end