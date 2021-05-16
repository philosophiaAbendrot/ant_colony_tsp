module GeneratorHelpers
	private

	# def generate_vertices(vertex_inputs)
	# 	vertex_inputs.each do |input|
	# 		Graph::Vertex.new(id: input[0], x_pos: input[1], y_pos: input[2])
	# 	end
	# end

	def generate_vertices(vertex_inputs)
		vertex_inputs.each do |input|
			Graph::Vertex.new(input)
		end
	end

	# def generate_edges(edge_inputs, default_pheromone_density)
	# 	edge_inputs.each do |input|
	# 		edge = Graph::Edge.new(id: input[0], cost_of_traversal: input[1], start_vertex_id: input[2], end_vertex_id: input[3])
	# 		edge.trail_density = default_pheromone_density
	# 	end
	# end

	def generate_edges(edge_inputs, default_pheromone_density)
		edge_inputs.each do |input|
			edge = Graph::Edge.new(input)
			edge.trail_density = default_pheromone_density
		end
	end
end