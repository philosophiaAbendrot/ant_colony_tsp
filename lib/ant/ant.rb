# Internal: Module which contains the Ant class for traversing the graph and
#   its supporting logic.
module Ant
	# Internal: Class used for traversing graph and marking it with
	#   pheromones.
	class Ant
		# Logic which stores instances and allow them to be searched.
		extend Databaseable

		# Internal: Gets/sets the id of the vertex the ant is currently on.
		attr_accessor :current_vertex_id
		#
		# Internal: Gets/sets the list of ids of the vertices that the ant has
		#   visited. 
		attr_accessor :visited_vertex_ids
		#
		# Internal: Gets/sets the list of ids of the edges that the ant has
		#   visited.
		attr_accessor :visited_edge_ids

		# Internal: Initialize ant
		#
		# current_vertex_id: The Integer id of the vertex that the ant starts
		#   on.
		# id - The Integer id of the ant.
		#
		# Returns nothing.
		def initialize(current_vertex_id:, id:)
			@id = id
			@current_vertex_id = current_vertex_id
			@visited_edge_ids = []
			@visited_vertex_ids = [current_vertex_id]

			nil
		end

		# Internal: Returns all ants to their original vertices.
		#
		# Returns nothing.
		def self.reset_to_original_position
			all.each do |ant|
				first_vertex_id = ant.visited_vertex_ids[0]
				ant.visited_vertex_ids = [first_vertex_id]
				ant.visited_edge_ids = []
				ant.current_vertex_id = first_vertex_id
			end

			nil
		end

		# Internal: Sets values of configurable class variables.
		#
		# config - Object used to configure various classes.
		#
		# Returns nothing.
		def self.set_config(config)
			# The vertex class.
			@@vertex_class = config.vertex_class
			
			# The edge class.
			@@edge_class = config.edge_class
			
			# Class used to generate random numbers.
			@@rand_gen = config.rand_gen
			
			# The amount of pheromone which is deposited by the ant which
			#   finds the shortest trail. This amount of pheromone is divided
			#   evenly among all the edges of the trail.
			@@q = config.q

			# alpha - coefficient controlling the importance of pheromone strength in
			#   influencing choice of next vertex.
			@@alpha = config.alpha
			# beta - coefficient controlling the importance of proximity in
			#   influencing choice of next vertex.
			@@beta = config.beta
			
			nil
		end

		# Internal: Return the vertex that the ant object is currently on.
		#
		# Returns the vertex object that the ant is currently on.
		def current_vertex
			@@vertex_class.find(@current_vertex_id)
		end

		# Internal: Returns the x_pos of the vertex that the ant is currently
		#   on.
		#
		# Returns the x_pos of the vertex that the ant is currently on.
		def x_pos
			current_vertex.x_pos
		end

		# Internal: Returns the y_pos of the vertex that the ant is currently
		#   on.
		#
		# Returns the x_pos of the vertex that the ant is currently on.
		def y_pos
			current_vertex.y_pos
		end

		# Internal: Makes the ant select a vertex to move to and move to it.
		#
		# Returns true if the ant successfully moved to the next vertex.
		#   Returns false if the ant has reached a dead end and cannot
		#   move. This can occur if there are no outgoing edges to vertice
		#   that haven't been visited, or if all vertices have been visited.
		def move_to_next_vertex
			# Evaluate preferences.
			outgoing_edges = current_vertex.outgoing_edge_ids.map { |edge_id| @@edge_class.find(edge_id) }

			# Generate a representation of the ant's preferences for each connected vertex.
			cumulative_preferences = VertexPreferenceGenerator.execute(outgoing_edges: outgoing_edges,
																	   visited_vertex_ids: @visited_vertex_ids.dup,
																	   alpha: @@alpha, beta: @@beta)

			# If there is no option to move to a vertex, terminate early and
			#   return false to indicate that no movement occurred.
			return false if cumulative_preferences.empty?

			# Use a random number to randomly select a vertex to move to based
			#   on the generated preferences.
			rand_num = @@rand_gen.rand_float

			selected_vertex_id = nil

			for i in 0..cumulative_preferences.length - 1
				vertex_id, cumulative_probability = cumulative_preferences[i]

				if cumulative_probability >= rand_num
					selected_vertex_id = vertex_id
					break
				end
			end

			# Find the edge that the ant must travel through to travel to the
			#   new vertex.
			selected_edge_id = outgoing_edges.select { |edge| edge.end_vertex_id == selected_vertex_id }.first.id

			# Move to new vertex.
			@current_vertex_id = selected_vertex_id
			@visited_vertex_ids << selected_vertex_id
			@visited_edge_ids << selected_edge_id

			# Return true to indicate that ant has moved successfully.
			true
		end

		# Internal: Returns an ant to the vertex that it started on if
		#   that vertex is directly connected to the current vertex.
		#   This method is used to return the ant to the starting
		#   vertex after it has visited every vertex.
		#
		# Returns true if the ant is successfully moved to its starting
		#   vertex and false otherwise.
		def move_to_start
			start_vertex_id = @visited_vertex_ids[0]

			outgoing_edges = current_vertex.outgoing_edge_ids.map { |edge_id| @@edge_class.find(edge_id) }

			prospective_edges = outgoing_edges.select { |edge| edge.end_vertex_id == start_vertex_id }

			return false if prospective_edges.empty?

			selected_edge_id = prospective_edges.first.id

			@current_vertex_id = start_vertex_id
			@visited_vertex_ids << start_vertex_id
			@visited_edge_ids << selected_edge_id

			true
		end

		# Internal: Calculates and returns the total path length of the path
		#   that the ant travelled starting from the start vertex.
		#
		# Returns the total travel length.
		def find_path_length
			@visited_edge_ids.map { |el| @@edge_class.find(el).cost_of_traversal }.sum
		end

		# Internal: Adds pheremones to all the edges that the ant travelled
		#   through on its path.
		def lay_pheromones
			trail_density = @@q / find_path_length

			@visited_edge_ids.map { |el| @@edge_class.find(el) }.each do |edge|
				edge.add_pheromones(trail_density)
			end

			nil
		end
	end
end