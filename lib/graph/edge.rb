module Graph
	class Edge
		extend Databaseable

		attr_accessor :trail_density, :delta_trail_density

		attr_reader :id, :start_vertex_id, :end_vertex_id, :cost_of_traversal

		def initialize(id:, cost_of_traversal:, start_vertex_id:, end_vertex_id:)
			@id = id
			@cost_of_traversal = cost_of_traversal.to_f
			@start_vertex_id = start_vertex_id
			@end_vertex_id = end_vertex_id
			@trail_density = 0.0
			@delta_trail_density = 0.0
		end

		def self.set_config(config)
			@@vertex_class = config.vertex_class
			@@rho = config.rho
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
			@@vertex_class.find(@start_vertex_id)
		end

		def end_vertex
			@@vertex_class.find(@end_vertex_id)
		end

		def add_pheromones(delta)
			@delta_trail_density = delta
		end
	end
end