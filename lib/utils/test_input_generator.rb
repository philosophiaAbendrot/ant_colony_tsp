require 'json'

class TestInputGenerator
	def initialize(num_vertices:, num_edges:)
		@num_vertices = num_vertices
		@num_edges = num_edges
	end

	def self.execute(num_vertices:, num_edges:)
		start_time = Time.now
		instance = new(num_vertices: num_vertices, num_edges: num_edges)
		instance.execute
		end_time = Time.now
		puts "Time taken = #{(end_time - start_time) * 1000} ms"
		true
	end

	def execute
		vertex_outputs = generate_vertex_inputs
		edge_outputs = generate_edge_inputs(vertex_outputs)
		write_results_to_file(vertex_outputs, edge_outputs)
	end

	def write_results_to_file(vertex_outputs, edge_outputs)
		File.open(__dir__ + "/test_data/test_vertex_inputs.json", "w") do |f|
			f.write("[")
			vertex_outputs.each do |line|
				f.write(line.to_json)
			end
			f.write("]")
		end

		File.open(__dir__ + "/test_data/test_edge_inputs.json", "w") do |f|
			f.write("[")
			edge_outputs.each do |line|
				f.write(line.to_json)
			end
			f.write("]")
		end

		true
	end

	def generate_vertex_inputs
		vertex_outputs = []

		for i in 0..@num_vertices - 1
			vertex_outputs << { id: i, x_pos: (40 * rand - 20).round(2), y_pos: (40 * rand - 20).round(2) }
		end

		vertex_outputs
	end

	def generate_edge_inputs(vertex_outputs)
		edge_outputs = []
		vertex_output_ids = vertex_outputs.map { |el| el[:id] }

		edge_id = 0

		# make sure every edge is connected to some other edge
		for vertex_output in vertex_outputs
			vertex_a_id = vertex_output[:id]
			vertex_b_id = vertex_output_ids.sample(1).first

			edge_outputs << { id: edge_id, start_vertex_id: vertex_a_id, end_vertex_id: vertex_b_id }
			edge_outputs << { id: edge_id + 1, start_vertex_id: vertex_b_id, end_vertex_id: vertex_a_id }
			edge_id += 2
		end


		for i in 0..((@num_edges - edge_outputs.length) / 2) - 1
			# make additional edges between random vertices
			vertex_a, vertex_b = vertex_outputs.sample(2)

			edge_outputs << { id: edge_id, start_vertex_id: vertex_a[:id], end_vertex_id: vertex_b[:id] }
			edge_outputs << { id: edge_id + 1, start_vertex_id: vertex_b[:id], end_vertex_id: vertex_a[:id] }
			edge_id += 2
		end

		# once all edges are generated, calculate the cost of traversal by multiplying distance between
		# start and end vertex and a random "difficulty" factor
		for i in 0..edge_outputs.length - 1
			edge_output = edge_outputs[i]
			difficulty = Math.exp(rand - 0.5)

			start_vertex_data = vertex_outputs[edge_output[:start_vertex_id]]
			end_vertex_data = vertex_outputs[edge_output[:end_vertex_id]]

			distance = Math.sqrt((end_vertex_data[:x_pos] - start_vertex_data[:x_pos])**2 + (end_vertex_data[:y_pos] - start_vertex_data[:y_pos])**2)
			edge_output[:cost_of_traversal] = (distance * difficulty).round(2)
		end

		edge_outputs
	end
end