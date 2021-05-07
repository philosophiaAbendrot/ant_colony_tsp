require 'json'
require 'pqueue'

class TestInputValidator
	def initialize
		start_time = Time.now
		@vertex_inputs = JSON.parse(File.read(__dir__ + "/test_data/test_vertex_inputs.json"))
		@edge_inputs = JSON.parse(File.read(__dir__ + "/test_data/test_edge_inputs.json"))
		end_time = Time.now
		puts "files read in #{(end_time - start_time) * 1_000} ms"
	end

	def self.execute
		new.execute
		true
	end

	def execute
		start_time = Time.now
		start_vertex_id = @vertex_inputs[0]["id"]
		distances = Dijkstra.execute(vertex_inputs: @vertex_inputs.dup, edge_inputs: @edge_inputs.dup, start_vertex_id: start_vertex_id)
		
		# check that all values are non-infinite
		valid = !distances.values.include?(Float::INFINITY)
		end_time = Time.now
		puts "compute time = #{(end_time - start_time) * 1_000} ms"
		valid
	end

	class Dijkstra
		def initialize(vertex_inputs:, edge_inputs:, start_vertex_id:)
			@vertex_inputs = vertex_inputs
			@edge_inputs = edge_inputs
			@vertex_hash = initialize_vertex_hash
			@start_vertex_id = start_vertex_id
			@edge_mat = generate_edge_matrix
		end

		def self.execute(vertex_inputs:, edge_inputs:, start_vertex_id:)
			new(vertex_inputs: vertex_inputs, edge_inputs: edge_inputs, start_vertex_id: start_vertex_id).execute
		end

		def execute
			dist = {}
			visited = {}

			for vertex_input in @vertex_inputs
				dist[vertex_input["id"]] = Float::INFINITY
			end

			dist[@start_vertex_id] = 0

			# vertex id is first element, distance is second element
			pq = PQueue.new { |a, b| a[1] > b[1] }
			pq.push([@start_vertex_id, 0])

			while !pq.empty?
				u_id, u_dist = pq.pop

				@edge_mat[u_id].compact.select { |edge_input| !visited.include?(edge_input["end_vertex_id"]) }.each do |edge_input|
					v_id = edge_input["end_vertex_id"]
					dist_uv = @edge_mat[u_id][v_id]["cost_of_traversal"]

					if u_dist + dist_uv < dist[v_id]
						dist[v_id] = u_dist + dist_uv
						pq.push([v_id, dist[v_id]])
					end
				end
			end

			dist
		end

		private

		def generate_edge_matrix
			edge_mat = Array.new(@vertex_inputs.length) { Array.new(@vertex_inputs.length) { nil } }

			for edge_input in @edge_inputs
				edge_mat[edge_input["start_vertex_id"]][edge_input["end_vertex_id"]] = edge_input
			end

			edge_mat
		end

		def initialize_vertex_hash
			vertex_hash = {}

			@vertex_inputs.each do |vertex_input|
				vertex_hash[vertex_input["id"]] = vertex_input
			end

			vertex_hash
		end
	end
end

result = TestInputValidator.execute
puts "data valid = #{result}"