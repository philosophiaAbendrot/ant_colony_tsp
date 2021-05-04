require 'spec_helper'

describe Ant::Ant do
	include GeneratorHelpers

	let(:current_vertex_id) { 5 }
	let!(:current_vertex) { Graph::Vertex.new(x_pos: -5, y_pos: 3, id: current_vertex_id) }
	let(:ant_id) { 1 }
	let(:initialize_params) { { current_vertex_id: current_vertex_id, vertex_class: Graph::Vertex, edge_class: Graph::Edge, id: ant_id } }
	let(:ant) { Ant::Ant.find(ant_id) }

	before(:each) do
		Ant::Ant.new(initialize_params)
	end

	after(:each) do
		Ant::Ant.destroy_all
		Graph::Vertex.destroy_all
	end

	describe "initialize" do
		it "ant should be initialized" do
			expect(ant).to_not be nil
		end

		it "should set current vertex id to the value in the parameters" do
			expect(ant.current_vertex_id).to eq current_vertex_id
		end

		it "should initialize visited edge ids to be a blank array" do
			expect(ant.visited_edge_ids).to eq []
		end

		it "should initialize visited vertex ids to an array that includes just the current_vertex_id" do
			expect(ant.visited_vertex_ids).to eq [current_vertex_id]
		end
	end

	describe "current_vertex" do
		it "should return the vertex associated with the Ant instance" do
			expect(ant.current_vertex).to eq current_vertex
		end
	end

	describe "x_pos" do
		it "should return the x_pos of the current_vertex" do
			expect(ant.x_pos).to eq current_vertex.x_pos
		end
	end

	describe "y_pos" do
		it "should return the y_pos of the current_vertex" do
			expect(ant.y_pos).to eq current_vertex.y_pos
		end
	end

	describe "move_to_next_city" do
		# vertices input format: [id, x_pos, y_pos]
		let(:vertex_inputs) { [[1, 5.3, 8.9 ], [2, -8.4, 7.2], [3, -4, -6], [4, 9.5, 5]] }
		# edges input format: [id, cost_of_traversal, start_vertex_id, end_vertex_id]
		let(:edge_inputs) { [[1, 4.6, 1, 3], [2, 9.5, 1, 4], [3, 7.3, 1, 2]] }
		let(:default_pheromone_density) { 3 }

		let(:mock_rand_gen) { double("rand_gen", rand_float: 0.5) }
		let(:initialize_params) { { current_vertex_id: current_vertex_id, vertex_class: Graph::Vertex, id: ant_id, edge_class: Graph::Edge, rand_gen: mock_rand_gen } }

		before(:each) do
			generate_vertices(vertex_inputs)
			generate_edges(edge_inputs, default_pheromone_density)

			# set up connections on the vertex the ant is on
			vertex_1 = Graph::Vertex.find(1)
			vertex_1.outgoing_edge_ids = [1, 2, 3]

			ant.current_vertex_id = 1
			ant.visited_vertex_ids = [1]
			ant.move_to_next_vertex
		end

		it "should move to the correct vertex" do
			edge_1 = Graph::Edge.find(1)
			tau_1_3 = (edge_1.trail_density)**AntColonyTsp::ALPHA_VALUE
			eta_1_3 = (1 / edge_1.cost_of_traversal)**AntColonyTsp::BETA_VALUE

			edge_2 = Graph::Edge.find(2)
			tau_1_4 = (edge_2.trail_density)**AntColonyTsp::ALPHA_VALUE
			eta_1_4 = (1 / edge_2.cost_of_traversal)**AntColonyTsp::BETA_VALUE

			edge_3 = Graph::Edge.find(3)
			tau_1_2 = (edge_3.trail_density)**AntColonyTsp::ALPHA_VALUE
			eta_1_2 = (1 / edge_3.cost_of_traversal)**AntColonyTsp::BETA_VALUE

			sum = (tau_1_3 * eta_1_3 + tau_1_4 * eta_1_4 + tau_1_2 * eta_1_2).to_f

			hashed_result = { edge_1.end_vertex_id => tau_1_3 * eta_1_3 / sum, edge_2.end_vertex_id => tau_1_4 * eta_1_4 / sum, edge_3.end_vertex_id => tau_1_2 * eta_1_2 / sum }
			cumulative_probability_mapping = []
			cumulative_prob = 0
			cumulative_prob += hashed_result[edge_1.end_vertex_id]
			cumulative_probability_mapping << [edge_1.end_vertex_id, cumulative_prob]

			cumulative_prob += hashed_result[edge_2.end_vertex_id]
			cumulative_probability_mapping << [edge_2.end_vertex_id, cumulative_prob]

			cumulative_prob += hashed_result[edge_3.end_vertex_id]
			cumulative_probability_mapping << [edge_3.end_vertex_id, cumulative_prob]

			expect(ant.current_vertex_id).to eq(4)
		end

		it "should have '4' in its list of visited vertices" do
			expect(ant.visited_vertex_ids.include?(4)).to be true
		end

		it "should have '2' in its list of visited edges" do
			expect(ant.visited_edge_ids.include?(2)).to be true
		end
	end
end