module Ant
	class Ant
		extend Databaseable

		attr_accessor :current_vertex_id, :visited_vertex_ids, :visited_edge_ids

		def initialize(current_vertex_id:, id:)
			@id = id
			@current_vertex_id = current_vertex_id
			@visited_edge_ids = []
			@visited_vertex_ids = [current_vertex_id]
		end

		def self.reset_to_original_position
			all.each do |ant|
				first_vertex_id = ant.visited_vertex_ids[0]
				ant.visited_vertex_ids = [first_vertex_id]
				ant.visited_edge_ids = []
				ant.current_vertex_id = first_vertex_id
			end
		end

		def self.set_config(config)
			@@vertex_class = config.vertex_class
			@@edge_class = config.edge_class
			@@rand_gen = config.rand_gen
			@@q = config.q
			@@alpha = config.alpha
			@@beta = config.beta
		end

		def current_vertex
			@@vertex_class.find(@current_vertex_id)
		end

		def x_pos
			current_vertex.x_pos
		end

		def y_pos
			current_vertex.y_pos
		end

		def move_to_next_vertex
			# evaluate preferences

			outgoing_edges = current_vertex.outgoing_edge_ids.map { |edge_id| @@edge_class.find(edge_id) }

			cumulative_preferences = VertexPreferenceGenerator.execute(outgoing_edges: outgoing_edges, visited_vertex_ids: @visited_vertex_ids.dup, alpha: @@alpha, beta: @@beta)

			# if there is no option to move to a vertex, terminate early and return false to indicate that no movement occurred

			return false if cumulative_preferences.empty?

			rand_num = @@rand_gen.rand_float

			selected_vertex_id = nil

			for i in 0..cumulative_preferences.length - 1
				vertex_id, cumulative_probability = cumulative_preferences[i]

				if cumulative_probability >= rand_num
					selected_vertex_id = vertex_id
					break
				end
			end

			selected_edge_id = outgoing_edges.select { |edge| edge.end_vertex_id == selected_vertex_id }.first.id

			# move to new vertex
			@current_vertex_id = selected_vertex_id
			@visited_vertex_ids << selected_vertex_id
			@visited_edge_ids << selected_edge_id

			# return true to indicate that ant has moved successfully
			true
		end

		def move_to_start
			start_vertex_id = @visited_vertex_ids[0]

			outgoing_edges = current_vertex.outgoing_edge_ids.map { |edge_id| @@edge_class.find(edge_id) }
			selected_edge_id = outgoing_edges.select { |edge| edge.end_vertex_id == start_vertex_id }.first.id

			@current_vertex_id = start_vertex_id
			@visited_vertex_ids << start_vertex_id
			@visited_edge_ids << selected_edge_id
		end

		def find_path_length
			@visited_edge_ids.map { |el| @@edge_class.find(el).cost_of_traversal }.sum
		end

		def lay_pheromones
			trail_density = @@q / find_path_length

			@visited_edge_ids.map { |el| @@edge_class.find(el) }.each do |edge|
				edge.add_pheromones(trail_density)
			end
		end
	end
end