require "spec_helper"
# require File.expand_path("../support/test_input_generator/base_graph_generator", __dir__)
require_relative "../support/test_input_generator/base_graph_generator"
require_relative "../support/test_input_generator/complete_graph_generator"
require_relative "../support/test_input_generator/incomplete_graph_generator"
require_relative "../support/test_input_generator/test_input_generator"

describe AntColonyTsp, type: :feature do
	let(:include_edges_data) { false }
	let(:include_path_length_vs_iteration) { false }

	def read_inputs_from_file
		edges_file_path = File.expand_path("../data/constant_difficulty/test_edge_inputs.json", __dir__)
		vertices_file_path = File.expand_path("../data/constant_difficulty/test_vertex_inputs.json", __dir__)
		edges_file = File.read(edges_file_path)
		vertices_file = File.read(vertices_file_path)
		edge_inputs = JSON.parse(edges_file)
		vertex_inputs = JSON.parse(vertices_file)
	end

	describe "running test with small data set" do
		let(:num_vertices) { 5 }
		let(:generated_inputs) { TestInputGenerator::TestInputGenerator.execute(complete_graph: true, num_vertices: num_vertices, write_to_file: false) }
		let(:edge_inputs) { generated_inputs[1] }
		let(:vertex_inputs) { generated_inputs[0] }
		let(:result) { AntColonyTsp.execute(edge_inputs: edge_inputs,
																				vertex_inputs: vertex_inputs,
																				include_edges_data: include_edges_data,
																				include_path_length_vs_iteration: include_path_length_vs_iteration) }

		it "the returned vertex list should have the same length as the number of input vertices" do
			expect(result[:vertices].length).to eq(num_vertices)
		end

		it "the returned vertex list should include every vertex id in the input" do
			vertex_ids = vertex_inputs.map { |el| el[:id] }
			expect(result[:vertices].sort).to eq(vertex_ids.sort)
		end

		it "should return a list of edge ids, all of which are included in the edges input" do
			edge_ids = edge_inputs.map { |el| el[:id] }

			for edge_id in result[:edges]
				expect(edge_ids.include?(edge_id)).to be true
			end
		end

		it "there should be num_vertices - 1 edges in the returned edge list" do
			expect(result[:edges].length).to eq(num_vertices - 1)
		end

		it "path length should equal the sum of the cost of traversals of the returned edge list" do
			path_edge_ids = result[:edges]
			expected_path_length = 0

			for edge_input in edge_inputs
				if path_edge_ids.include?(edge_input[:id])
					expected_path_length += edge_input[:cost_of_traversal]
				end
			end

			diff = (expected_path_length - result[:path_length]).abs
			percent_diff = diff / ((expected_path_length + result[:path_length]) / 2.0) * 100

			expect(percent_diff < 0.1).to be true
		end
	end
end