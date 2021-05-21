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
			expect(percent_diff).to be < 0.1
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

	describe "checking against exact solutions for small complete graphs" do
		let(:num_vertices) { 8 }
		let(:num_tests) { 20 }

		# this test could theoretically fail very rarely
		it "on average, should be within 10\% of exact solution" do
			aco_path_lengths = []
			exact_solutions = []

			for i in 0..num_tests - 1
				vertex_inputs, edge_inputs = TestInputGenerator::TestInputGenerator.execute(complete_graph: true, num_vertices: num_vertices, write_to_file: false)

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

			expect(avg_percent_error).to be < 10
		end
	end

	describe "checking that path lengths found for large complete graphs decay during iteration process" do
		let(:num_vertices) { 50 }
		let(:generated_inputs) { TestInputGenerator::TestInputGenerator.execute(complete_graph: true, num_vertices: num_vertices, write_to_file: false) }
		let(:num_tests) { 10 }
		let(:include_path_length_vs_iteration) { true }

		it "path length should decay" do
			puts "running large scale tests with AntColonyTsp"
			initial_path_lengths = []
			path_length_set = []

			for i in 0..num_tests - 1
				puts "running test #{i}"
				vertex_inputs, edge_inputs = TestInputGenerator::TestInputGenerator.execute(complete_graph: true, num_vertices: num_vertices, write_to_file: false)
				result = run_ants(edge_inputs, vertex_inputs)
				initial_path_lengths << result[:iteration_path_lengths][0]
				path_length_set << result[:path_length]
			end

			ratio = []

			for i in 0..path_length_set.length - 1
				ratio << initial_path_lengths[i] / path_length_set[i].to_f
			end

			mean_ratio = ratio.sum / ratio.length.to_f
			expect(mean_ratio).to be > 1.8
		end
	end 

	describe "testing incomplete graphs" do
		let(:num_vertices) { 50 }
		let(:vertices_degree) { 18 }
		let(:generated_inputs) { TestInputGenerator::TestInputGenerator.execute(complete_graph: false,
																																					  num_vertices: num_vertices,
																																					  write_to_file: false,
																																					  vertices_degree: vertices_degree) }
		describe "testing reliability with incomplete graphs" do
			def multiple_executions_with_incomplete_graphs
				for i in 0..num_tests - 1
					vertex_inputs, edge_inputs = generated_inputs
					result = run_ants(edge_inputs, vertex_inputs)
				end
			end

			let(:num_tests) { 10 }

			it "failures with incomplete graphs should be rare" do
				expect(multiple_executions_with_incomplete_graphs).to_not raise_error
			end
		end

		describe "testing that an error is raised when there is a failure to compute a path" do
			let(:vertex_inputs) { [{ id: 1, x_pos: 5.4, y_pos: 3.1 }, { id: 2, x_pos: -5.1, y_pos: -9.1 }, { id: 3, x_pos: -19.1, y_pos: 10.0 }, { id: 4, x_pos: -4.8, y_pos: -3.9 }] }
			let(:edge_inputs) { [{ id: 1, start_vertex_id: 1, end_vertex_id: 2, cost_of_traversal: 8.1 }, { id: 2, start_vertex_id: 2, end_vertex_id: 1, cost_of_traversal: 1.8 },
													 { id: 3, start_vertex_id: 3, end_vertex_id: 4, cost_of_traversal: 4.1 }, { id: 4, start_vertex_id: 4, end_vertex_id: 3, cost_of_traversal: 9.7 }] }

			it "should raise a AntColonyTsp::PathNotFound error" do
				expect(run_ants(edge_inputs, vertex_inputs)).to raise_error(AntColonyTsp::PathNotFound)
			end
		end
	end
end