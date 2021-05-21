require 'spec_helper'

describe Ant::Ant do
	include GeneratorHelpers

	let(:current_vertex_id) { 5 }
	let!(:current_vertex) { Graph::Vertex.new(x_pos: -5, y_pos: 3, id: current_vertex_id) }
	let(:ant_id) { 1 }
	let(:config) { Config.new.process_configs }
	let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }
	let(:ant) { Ant::Ant.find(ant_id) }

	before(:each) do
		Graph::Graph.set_config(config)
		Graph::Edge.set_config(config)
		Ant::Ant.set_config(config)
	end

	after(:each) do
		Ant::Ant.destroy_all
		Graph::Vertex.destroy_all
		Graph::Edge.destroy_all
	end

	describe "initialize" do
		before(:each) do
			Ant::Ant.set_config(config)
			Ant::Ant.new(initialize_params)
		end

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
		before(:each) do
			Ant::Ant.new(initialize_params)
		end

		it "should return the vertex associated with the Ant instance" do
			expect(ant.current_vertex).to eq current_vertex
		end
	end

	describe "x_pos" do
		before(:each) do
			Ant::Ant.new(initialize_params)
		end

		it "should return the x_pos of the current_vertex" do
			expect(ant.x_pos).to eq current_vertex.x_pos
		end
	end

	describe "y_pos" do
		before(:each) do
			Ant::Ant.new(initialize_params)
		end

		it "should return the y_pos of the current_vertex" do
			expect(ant.y_pos).to eq current_vertex.y_pos
		end
	end

	describe "move_to_next_city" do
		let(:vertex_inputs) { [{ id: 1, x_pos: 5.3, y_pos: 8.9 }, {id: 2, x_pos: -8.4, y_pos: 7.2}, {id: 3, x_pos: -4, y_pos: -6}, { id: 4, x_pos: 9.5, y_pos: 5 }] }
		let(:edge_inputs) { [{ id: 1, cost_of_traversal: 4.6, start_vertex_id: 1, end_vertex_id: 3 },
												 { id: 2, cost_of_traversal: 9.5, start_vertex_id: 1, end_vertex_id: 4 },
												 { id: 3, cost_of_traversal: 7.3, start_vertex_id: 1, end_vertex_id: 2 }] }

		let(:mock_rand_gen) { double("rand_gen", rand_float: 0.5) }
		let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }

		before(:each) do
			config.rand_gen = mock_rand_gen
			config.process_configs
			Ant::Ant.set_config(config)

			generate_vertices(vertex_inputs)
			generate_edges(edge_inputs, config.initial_trail_density)

			# set up connections on the vertex the ant is on
			Ant::Ant.new(initialize_params)
			Graph::Vertex.find(1).outgoing_edge_ids = [1, 2, 3]
			ant.current_vertex_id = 1
			ant.visited_vertex_ids = [1]
		end

		it "should move to the correct vertex" do
			ant.move_to_next_vertex

			# calculate what answer should be
			# edge_1 = Graph::Edge.find(1)
			# tau_1_3 = (edge_1.trail_density)**AntColonyTsp::ALPHA_VALUE
			# eta_1_3 = (1 / edge_1.cost_of_traversal)**AntColonyTsp::BETA_VALUE

			# edge_2 = Graph::Edge.find(2)
			# tau_1_4 = (edge_2.trail_density)**AntColonyTsp::ALPHA_VALUE
			# eta_1_4 = (1 / edge_2.cost_of_traversal)**AntColonyTsp::BETA_VALUE

			# edge_3 = Graph::Edge.find(3)
			# tau_1_2 = (edge_3.trail_density)**AntColonyTsp::ALPHA_VALUE
			# eta_1_2 = (1 / edge_3.cost_of_traversal)**AntColonyTsp::BETA_VALUE

			# sum = (tau_1_3 * eta_1_3 + tau_1_4 * eta_1_4 + tau_1_2 * eta_1_2).to_f

			# hashed_result = { edge_1.end_vertex_id => tau_1_3 * eta_1_3 / sum, edge_2.end_vertex_id => tau_1_4 * eta_1_4 / sum, edge_3.end_vertex_id => tau_1_2 * eta_1_2 / sum }
			# cumulative_probability_mapping = []
			# cumulative_prob = 0
			# cumulative_prob += hashed_result[edge_1.end_vertex_id]
			# cumulative_probability_mapping << [edge_1.end_vertex_id, cumulative_prob]

			# cumulative_prob += hashed_result[edge_2.end_vertex_id]
			# cumulative_probability_mapping << [edge_2.end_vertex_id, cumulative_prob]

			# cumulative_prob += hashed_result[edge_3.end_vertex_id]
			# cumulative_probability_mapping << [edge_3.end_vertex_id, cumulative_prob]

			expect(ant.current_vertex_id).to eq(4)
		end

		it "should return true to indicate that the ant moved successfully" do
			expect(ant.move_to_next_vertex).to be true
		end

		it "should have '4' in its list of visited vertices" do
			ant.move_to_next_vertex
			expect(ant.visited_vertex_ids.include?(4)).to be true
		end

		it "should have '2' in its list of visited edges" do
			ant.move_to_next_vertex
			expect(ant.visited_edge_ids.include?(2)).to be true
		end

		context "if there is no connected vertex which has not been visited" do
			before(:each) do
				ant.visited_vertex_ids = [2, 3, 4]
			end

			it "ant should not move" do
				ant.move_to_next_vertex
				expect(ant.current_vertex_id).to eq(1)
			end

			it "should return false to indicate that ant did not move" do
				expect(ant.move_to_next_vertex).to be false
			end
		end
	end

	describe "move_to_start" do
		let(:vertex_inputs) { [{:id=>0, :x_pos=>-18.14, :y_pos=>-19.13}, {:id=>1, :x_pos=>16.25, :y_pos=>-9.67}, {:id=>2, :x_pos=>-3.01, :y_pos=>5.7}, {:id=>3, :x_pos=>-17.55, :y_pos=>-15.14}, {:id=>4, :x_pos=>7.29, :y_pos=>9.51}] }
		let(:edge_inputs) { [{:id=>0, :start_vertex_id=>0, :end_vertex_id=>1, :cost_of_traversal=>35.66740388646193}, {:id=>1, :start_vertex_id=>0, :end_vertex_id=>2, :cost_of_traversal=>29.076550689516115}, {:id=>2, :start_vertex_id=>0, :end_vertex_id=>3, :cost_of_traversal=>4.033385674591507}, {:id=>3, :start_vertex_id=>0, :end_vertex_id=>4, :cost_of_traversal=>38.30058093554195}, {:id=>4, :start_vertex_id=>1, :end_vertex_id=>0, :cost_of_traversal=>35.66740388646193}, {:id=>5, :start_vertex_id=>1, :end_vertex_id=>2, :cost_of_traversal=>24.641114017024474}, {:id=>6, :start_vertex_id=>1, :end_vertex_id=>3, :cost_of_traversal=>34.23975613230912}, {:id=>7, :start_vertex_id=>1, :end_vertex_id=>4, :cost_of_traversal=>21.169648083990438}, {:id=>8, :start_vertex_id=>2, :end_vertex_id=>0, :cost_of_traversal=>29.076550689516115}, {:id=>9, :start_vertex_id=>2, :end_vertex_id=>1, :cost_of_traversal=>24.641114017024474}, {:id=>10, :start_vertex_id=>2, :end_vertex_id=>3, :cost_of_traversal=>25.410966136689886}, {:id=>11, :start_vertex_id=>2, :end_vertex_id=>4, :cost_of_traversal=>10.982080859290738}, {:id=>12, :start_vertex_id=>3, :end_vertex_id=>0, :cost_of_traversal=>4.033385674591507}, {:id=>13, :start_vertex_id=>3, :end_vertex_id=>1, :cost_of_traversal=>34.23975613230912}, {:id=>14, :start_vertex_id=>3, :end_vertex_id=>2, :cost_of_traversal=>25.410966136689886}, {:id=>15, :start_vertex_id=>3, :end_vertex_id=>4, :cost_of_traversal=>34.99497249606006}, {:id=>16, :start_vertex_id=>4, :end_vertex_id=>0, :cost_of_traversal=>38.30058093554195}, {:id=>17, :start_vertex_id=>4, :end_vertex_id=>1, :cost_of_traversal=>21.169648083990438}, {:id=>18, :start_vertex_id=>4, :end_vertex_id=>2, :cost_of_traversal=>10.982080859290738}, {:id=>19, :start_vertex_id=>4, :end_vertex_id=>3, :cost_of_traversal=>34.99497249606006}] }
		let(:current_vertex_id) { 4 }
		let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }
		let(:move_ant) { ant.move_to_start }


		before(:each) do
			generate_vertices(vertex_inputs)
			generate_edges(edge_inputs, config.initial_trail_density)
			Ant::Ant.new(initialize_params)
			Graph::Vertex.find(4).outgoing_edge_ids = [16, 17, 18, 19]
			ant.visited_vertex_ids = [0, 1, 2, 3, 4]
			ant.visited_edge_ids = [0, 5, 10, 15]
		end

		it "should move to the correct vertex" do
			result = move_ant
			expect(ant.current_vertex).to eq(Graph::Vertex.find(0))
		end

		it "should return true to indicate that the ant moved successfully" do
			result = move_ant
			expect(result).to be true
		end

		it "should have the first vertex twice in its list of visited vertices" do
			move_ant
			expect(ant.visited_vertex_ids[0]).to eq(ant.visited_vertex_ids[-1])
		end

		it "should have the edge that connects the last vertex to the first vertex in its list of visited edges" do
			move_ant
			expect(ant.visited_edge_ids[-1]).to eq(16)
		end

		context "if there is no connected vertex which has not been visited" do
			let(:edge_inputs) { [{:id=>0, :start_vertex_id=>0, :end_vertex_id=>1, :cost_of_traversal=>35.66740388646193}, {:id=>1, :start_vertex_id=>0, :end_vertex_id=>2, :cost_of_traversal=>29.076550689516115}, {:id=>2, :start_vertex_id=>0, :end_vertex_id=>3, :cost_of_traversal=>4.033385674591507}, {:id=>3, :start_vertex_id=>0, :end_vertex_id=>4, :cost_of_traversal=>38.30058093554195}, {:id=>4, :start_vertex_id=>1, :end_vertex_id=>0, :cost_of_traversal=>35.66740388646193}, {:id=>5, :start_vertex_id=>1, :end_vertex_id=>2, :cost_of_traversal=>24.641114017024474}, {:id=>6, :start_vertex_id=>1, :end_vertex_id=>3, :cost_of_traversal=>34.23975613230912}, {:id=>7, :start_vertex_id=>1, :end_vertex_id=>4, :cost_of_traversal=>21.169648083990438}, {:id=>8, :start_vertex_id=>2, :end_vertex_id=>0, :cost_of_traversal=>29.076550689516115}, {:id=>9, :start_vertex_id=>2, :end_vertex_id=>1, :cost_of_traversal=>24.641114017024474}, {:id=>10, :start_vertex_id=>2, :end_vertex_id=>3, :cost_of_traversal=>25.410966136689886}, {:id=>11, :start_vertex_id=>2, :end_vertex_id=>4, :cost_of_traversal=>10.982080859290738}, {:id=>12, :start_vertex_id=>3, :end_vertex_id=>0, :cost_of_traversal=>4.033385674591507}, {:id=>13, :start_vertex_id=>3, :end_vertex_id=>1, :cost_of_traversal=>34.23975613230912}, {:id=>14, :start_vertex_id=>3, :end_vertex_id=>2, :cost_of_traversal=>25.410966136689886}, {:id=>15, :start_vertex_id=>3, :end_vertex_id=>4, :cost_of_traversal=>34.99497249606006}, {:id=>17, :start_vertex_id=>4, :end_vertex_id=>1, :cost_of_traversal=>21.169648083990438}, {:id=>18, :start_vertex_id=>4, :end_vertex_id=>2, :cost_of_traversal=>10.982080859290738}, {:id=>19, :start_vertex_id=>4, :end_vertex_id=>3, :cost_of_traversal=>34.99497249606006}] }

			before(:each) do
				Graph::Vertex.find(4).outgoing_edge_ids = [17, 18, 19]
			end

			it "ant should not move" do
				move_ant
				expect(ant.current_vertex_id).to eq(current_vertex_id)
			end

			it "should not change visited vertex ids" do
				move_ant
				expect(ant.visited_vertex_ids).to eq([0, 1, 2, 3, 4])
			end

			it "should not change visited edge ids" do
				move_ant
				expect(ant.visited_edge_ids).to eq([0, 5, 10, 15])
			end

			it "should return false to indicate that the ant did not move" do
				expect(move_ant).to be false
			end
		end
	end

	describe "find_path_length" do
		let(:vertex_inputs) { [{ id: 1, x_pos: 5.3, y_pos: 8.9}, { id: 2, x_pos: -8.4, y_pos: 7.2 }, { id: 3, x_pos: -4, y_pos: -6 }] }
		let(:edge_inputs) { [{ id: 1, cost_of_traversal: 5.3, start_vertex_id: 1, end_vertex_id: 2 },
												 { id: 2, cost_of_traversal: 7.0, start_vertex_id: 2, end_vertex_id: 3 },
												 { id: 3, cost_of_traversal: 1.1, start_vertex_id: 3, end_vertex_id: 1 }] }
		let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }

		before(:each) do
			generate_vertices(vertex_inputs)
			generate_edges(edge_inputs, config.initial_trail_density)

			Ant::Ant.new(initialize_params)

			# set up connections on the vertex the ant is on
			Graph::Vertex.find(1).outgoing_edge_ids = [1, 2, 3]

			ant.current_vertex_id = 1
			ant.visited_vertex_ids = [1, 2, 3]
			ant.visited_edge_ids = [1, 2, 3]
		end

		it "should return the correct path length" do
			expected_length = edge_inputs.map { |el| el[:cost_of_traversal] }.sum
			expect(ant.find_path_length).to eq(expected_length)
		end
	end

	describe "lay_phermones" do
		let(:vertex_inputs) { [{ id: 1, x_pos: 5.3, y_pos: 8.9}, { id: 2, x_pos: -8.4, y_pos: 7.2 }, { id: 3, x_pos: -4, y_pos: -6 }] }
		let(:edge_inputs) { [{ id: 1, cost_of_traversal: 5.3, start_vertex_id: 1, end_vertex_id: 2 },
												 { id: 2, cost_of_traversal: 7.0, start_vertex_id: 2, end_vertex_id: 3 },
												 { id: 3, cost_of_traversal: 1.1, start_vertex_id: 3, end_vertex_id: 1 }] }
		let(:mock_edge_class) { double("mock_edge_class", all: [mock_edge_1, mock_edge_2, mock_edge_3]) }
		let(:mock_edge_1) { double("edge1", cost_of_traversal: 5.3) }
		let(:mock_edge_2) { double("edge2", cost_of_traversal: 7.0) }
		let(:mock_edge_3) { double("edge3", cost_of_traversal: 1.1) }
		let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }
		let(:q) { 5 }

		before(:each) do
			config.q = q
			config.edge_class = mock_edge_class
			config.process_configs

			Ant::Ant.set_config(config)
			Ant::Ant.new(initialize_params)

			generate_vertices(vertex_inputs)
			generate_edges(edge_inputs, config.initial_trail_density)

			allow(mock_edge_class).to receive(:find).with(1).and_return(mock_edge_1)
			allow(mock_edge_class).to receive(:find).with(2).and_return(mock_edge_2)
			allow(mock_edge_class).to receive(:find).with(3).and_return(mock_edge_3)

			# set up connections on the vertex the ant is on
			vertex_1 = Graph::Vertex.find(1)
			vertex_1.outgoing_edge_ids = [1, 2, 3]

			ant.current_vertex_id = 1
			ant.visited_vertex_ids = [1, 2, 3]
			ant.visited_edge_ids = [1, 2, 3]
		end

		it "should call add_pheromones with delta value Q/Lk on each edge" do
			expected_density = q.to_f / ant.find_path_length
			expect(mock_edge_1).to receive(:add_pheromones).with(expected_density)
			expect(mock_edge_2).to receive(:add_pheromones).with(expected_density)
			expect(mock_edge_3).to receive(:add_pheromones).with(expected_density)
			ant.lay_pheromones
		end
	end

	describe "reset_to_original_position" do
		let(:vertex_inputs) { [{ id: 1, x_pos: 5.3, y_pos: 8.9}, { id: 2, x_pos: -8.4, y_pos: 7.2 }, { id: 3, x_pos: -4, y_pos: -6 }] }
		let(:edge_inputs) { [{ id: 1, cost_of_traversal: 5.3, start_vertex_id: 1, end_vertex_id: 2 },
												 { id: 2, cost_of_traversal: 7.0, start_vertex_id: 2, end_vertex_id: 3 },
												 { id: 3, cost_of_traversal: 1.1, start_vertex_id: 3, end_vertex_id: 1 }] }
		let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }

		before(:each) do
			generate_vertices(vertex_inputs)
			generate_edges(edge_inputs, config.initial_trail_density)

			Ant::Ant.new(initialize_params)

			# set up connections on the vertex the ant is on
			vertex_1 = Graph::Vertex.find(1)
			vertex_1.outgoing_edge_ids = [1, 2, 3]

			ant.current_vertex_id = 3
			ant.visited_vertex_ids = [1, 2, 3]
			ant.visited_edge_ids = [1, 2, 3]
		end

		it "should clear visited edge ids" do
			Ant::Ant.reset_to_original_position
			expect(ant.visited_edge_ids).to eq([])
		end

		it "should clear visited vertex ids" do
			original_vertex_id = ant.visited_vertex_ids[0]
			Ant::Ant.reset_to_original_position
			expect(ant.visited_vertex_ids).to eq([original_vertex_id])
		end

		it "should place ant in the original position" do
			original_vertex_id = ant.visited_vertex_ids[0]
			Ant::Ant.reset_to_original_position
			expect(ant.current_vertex_id).to eq(original_vertex_id)
		end
	end
end