module Graph
	class Edge
		extend Databaseable

		@@rho = nil

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

		def self.set_trail_persistence(rho)
			@@rho = rho.to_f
		end

		def self.set_trail_densities(set_value)
			# set trail density to a set value for all edges
			all.each do |edge|
				edge.trail_density = set_value
			end
		end

		def self.update_trail_densities
			all.each do |edge|
				edge.trail_density = edge.trail_density * @@rho + edge.delta_trail_density
				edge.delta_trail_density = 0.0
			end
		end

		def start_vertex
			@vertex_class.find(@start_vertex_id)
		end

		def end_vertex
			@vertex_class.find(@end_vertex_id)
		end

		def add_pheromones(delta)
			@delta_trail_density = delta
		end
	end
end