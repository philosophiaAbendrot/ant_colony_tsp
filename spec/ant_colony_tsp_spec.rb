require "spec_helper"

describe AntColonyTsp do
	let(:edge_params) { [[1, 3, 4, 5.0], [2, 4, 3, 3.0]] }
	let(:vertex_params) { [[3, 4.0, 5.0], [4, 5.0, 6.0]] }
	let(:mock_graph_class) { class_double("Graph::Graph") }
	let(:mock_ant_class) { class_double("Ant::Ant") }
	let(:rand_gen_double) { double("rand_gen", rand_int: 5) }
	let(:num_ants) { AntColonyTsp::DEFAULT_NUM_ANTS }
	let(:num_iterations) { AntColonyTsp::DEFAULT_NUM_ITERATIONS }

	describe "initialize" do
		before(:each) do
			allow(mock_ant_class).to receive(:all).and_return(Array.new(AntColonyTsp::DEFAULT_NUM_ANTS) { double("ant_element", id: 5) })
		end

		def initialize_ant_colony_tsp
			AntColonyTsp.new(edges: edge_params,
							vertices: vertex_params,
							graph_class: mock_graph_class,
							vertex_class: Graph::Vertex,
							edge_class: Graph::Edge,
							ant_class: mock_ant_class,
							rand_gen: rand_gen_double,
							num_ants: num_ants,
							num_iterations: num_iterations)
		end

		describe "testing initialization of graph" do
			before(:each) do
				allow(mock_ant_class).to receive(:new)
			end

			it "should call initialize on provided Graph class with the correct parameters" do
				allow(mock_ant_class).to receive(:new)
				expect(mock_graph_class).to receive(:new).with(hash_including(edges: edge_params, vertices: vertex_params, vertex_class: Graph::Vertex, edge_class: Graph::Edge))
				initialize_ant_colony_tsp
			end
		end

		describe "testing initialization of ant class" do
			# replace mock ant class with real class
			let(:ant) { Ant::Ant.all.first }

			before(:each) do
				allow(mock_graph_class).to receive(:new)
			end

			it "should call initialize on provided Ant class with the correct parameters" do
				expect(mock_ant_class).to receive(:new).exactly(num_ants).times.with(hash_including(current_vertex_id: rand_gen_double.rand_int, vertex_class: Graph::Vertex))
				initialize_ant_colony_tsp
			end

			it "should call initialize on provided Ant class AntColonyTsp::NUM_ANTS times" do
				expect(mock_ant_class).to receive(:new).exactly(num_ants).times
				initialize_ant_colony_tsp
			end
		end

		describe "testing placement of ant instances" do
			let(:rand_gen_double) { class_double("Utils::RandGen") }

			before(:each) do
				allow(rand_gen_double).to receive(:rand_int).and_return(num_ants - 1)
				allow(mock_graph_class).to receive(:new)
				allow(mock_ant_class).to receive(:new)
			end

			it "should call rand_int on Utils::RandGen class with the number of ants currently existing" do
				expect(rand_gen_double).to receive(:rand_int).with(num_ants)
				initialize_ant_colony_tsp
			end
		end
	end
end