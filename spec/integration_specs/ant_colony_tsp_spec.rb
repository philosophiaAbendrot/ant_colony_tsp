require "spec_helper"
require_relative "../support/test_input_generator/base_graph_generator"
require_relative "../support/test_input_generator/complete_graph_generator"
require_relative "../support/test_input_generator/incomplete_graph_generator"
require_relative "../support/test_input_generator/test_input_generator"
require_relative "../support/exact_solution_finder"

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

	def find_percent_error(true_value, observed_value)
		(observed_value - true_value) / true_value.to_f * 100
	end

	after(:each) do
		Graph::Vertex.destroy_all
		Graph::Edge.destroy_all
		Ant::Ant.destroy_all
	end

	describe "doing sanity checks on outputs with small input graphs" do
		let(:num_vertices) { 10 }
		let(:generated_inputs) { TestInputGenerator::TestInputGenerator.execute(complete_graph: true, num_vertices: num_vertices, write_to_file: false) }
		let(:edge_inputs) { generated_inputs[1] }
		let(:vertex_inputs) { generated_inputs[0] }
		let(:result) { AntColonyTsp.execute(edge_inputs: edge_inputs,
																				vertex_inputs: vertex_inputs,
																				include_edges_data: include_edges_data,
																				include_path_length_vs_iteration: include_path_length_vs_iteration) }

		it "the returned vertex list should have the same length as the number of input vertices" do
			expect(result[:vertices].length).to eq(num_vertices + 1)
		end

		it "the returned vertex list should include every vertex id in the input" do
			vertex_ids = vertex_inputs.map { |el| el[:id] }
			expect(result[:vertices].uniq.sort).to eq(vertex_ids.sort)
		end

		it "should return a list of edge ids, all of which are included in the edges input" do
			edge_ids = edge_inputs.map { |el| el[:id] }

			for edge_id in result[:edges]
				expect(edge_ids.include?(edge_id)).to be true
			end
		end

		it "there should be num_vertices edges in the returned edge list" do
			expect(result[:edges].length).to eq(num_vertices)
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

		context "when 'include_edges_data' is set to true" do
			let(:include_edges_data) { true }

			it "edges_data should have same length as input edges" do
				expect(result[:edges_data].length).to eq(edge_inputs.length)
			end

			it "edges data should be equivalent to input edges" do
				edge_data = result[:edges_data]

				for input_edge in edge_inputs
					edge_data_pair = edge_data[input_edge[:id]]
					expect(edge_data_pair[:start_vertex_id]).to eq(input_edge[:start_vertex_id])
				end
			end
		end

		context "when include_path_length_vs_iteration is set to true" do
			let(:include_path_length_vs_iteration) { true }

			it "path length output should have same length as 'num_iterations' config variable" do
				expect(result[:iteration_path_lengths].length).to eq(AntColonyTsp.config.num_iterations)
			end
		end
	end

	describe "checking against exact solutions for small input graphs" do
		let(:num_vertices) { 8 }
		let(:generated_inputs) { TestInputGenerator::TestInputGenerator.execute(complete_graph: true, num_vertices: num_vertices, write_to_file: false) }
		let(:num_tests) { 20 }

		def generate_inputs(num_vertices)
			TestInputGenerator::TestInputGenerator.execute(complete_graph: true, num_vertices: num_vertices, write_to_file: false)
		end

		def find_exact_solution(edge_inputs, vertex_inputs)
			ExactSolutionFinder.call(vertex_inputs, edge_inputs)
		end

		def run_ants(edge_inputs, vertex_inputs)
			AntColonyTsp.execute(edge_inputs: edge_inputs,
													 vertex_inputs: vertex_inputs,
													 include_edges_data: include_edges_data,
													 include_path_length_vs_iteration: include_path_length_vs_iteration)
		end

		# this test could theoretically fail very rarely
		it "on average, should be within 10\% of exact solution" do
			aco_path_lengths = []
			exact_solutions = []

			for i in 0..num_tests - 1
				vertex_inputs, edge_inputs = generate_inputs(num_vertices)

				result = run_ants(edge_inputs, vertex_inputs)
				exact_min_path_length, _ = find_exact_solution(edge_inputs, vertex_inputs)
				exact_solutions << exact_min_path_length
				aco_path_lengths << result[:path_length]
			end

			percent_errors = []

			for i in 0..num_tests - 1
				percent_errors << find_percent_error(exact_solutions[i], aco_path_lengths[i])
			end

			avg_percent_error = percent_errors.sum / percent_errors.length.to_f

			expect(avg_percent_error < 10).to be true
		end
	end
end