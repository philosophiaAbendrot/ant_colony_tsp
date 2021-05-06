require 'json'
require 'pqueue'

# https://www.youtube.com/watch?v=_lHSawdgXpI
# pseudocode for Dijkstra's algorithm
# dijkstra tells us the shortest path from one node to every other node
# method dijkstra(start_vertex, graph)
# 	let unvisited_nodes be a set of all the vertices in graph minus the start_vertex
# 	let distances be a hash table mapping vertex ids to distances, set to infinity by default
# 	let distances[start_node.id] = 0
#   let queue be a priority queue of edges, prioritizing them such that the edge with the lowest cost of traversal will be extracted when pop is called
#   push all edges connected to start_node into queue

#   loop while queue is not empty
#     pop the shortest edge in queue into e
#     let v be the vertex that is the end vertex of e
#     remove v from unvisited_nodes
#     distances[v] = distances[]
#   end loop
# end method


class TestInputValidator
	def initialize
		@vertex_inputs = JSON.parse(File.read(__dir__ + "/test_data/test_vertex_inputs.json"))
		@edge_inputs = JSON.parse(File.read(__dir__ + "/test_data/test_edge_inputs.json"))
	end

	def self.execute
		new.execute
		true
	end

	class Dijkstra
		def initialize(vertex_inputs:, edge_inputs:)
			@vertex_inputs = vertex_inputs
			@vertex_hash = initialize_vertex_hash
			@edge_inputs = edge_inputs
			@edge_mat = initialize_edge_matrix
		end

		def execute(start_vertex_id)
			@adj_mat = generate_adjacency_matrix(vertex_inputs, edge_inputs)
			@dist = {}
			@prev = {}
			# queue elements will be edge inputs
			queue = PQueue.new { |a, b| a[:cost_of_traversal] < b[:cost_of_traversal] }
			vertices_in_queue = {}

			@vertex_inputs.each do |vertex_input|
				@dist[vertex_input[:id]] = Float::INFINITY
				@prev[vertex_input[:id]] = nil
				queue.push(@edge_mat[start_vertex_id][vertex_input[:id]])
				vertices_in_queue[vertex_input[:id]] = true
			end

			@dist[start_vertex_id] = 0
			
			while !queue.empty?
				edge_to_u = queue.pop
				u = @vertex_hash[edge_to_u[:end_vertex_id]]
				vertices_in_queue.delete(u[:id])

				# for each neighbour v of u that are still in Q:
				@edge_mat[u[:id]].select { |val| val != -1 && vertices_in_queue.include?(val) }
			end
		end

		private

		def generate_edge_matrix(vertex_inputs, edge_inputs)
			edge_mat = Array.new(vertex_inputs.length) { Array.new(vertex_inputs.length) { -1 } }

			for edge_input in edge_inputs
				edge_mat[edge_input[:start_vertex_id]][edge_input[:end_vertex_id]] = edge_input
			end

			edge_mat
		end

		def initialize_vertex_hash
			vertex_hash = {}

			@vertex_inputs.each do |vertex_input|
				vertex_hash[vertex_input[:id]] = vertex_input
			end

			vertex_hash
		end
	end

	def execute
		start_vertex_id = vertex_inputs[0][:id]
		instance = Dijkstra.new(vertex_inputs: @vertex_inputs.dup, edge_inputs: @edge_inputs.dup)
		instance.execute(start_vertex_id)
	end
end