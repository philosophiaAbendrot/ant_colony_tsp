require "spec_helper"

describe AntColonyTsp do
	let(:edge_params) { [[1, 3, 4, 5.0], [2, 4, 3, 3.0]] }
	let(:vertex_params) { [[3, 4.0, 5.0], [4, 5.0, 6.0]] }
	let(:mock_graph_class) { class_double("Graph::Graph") }
	let(:mock_ant_class) { class_double("Ant") }
	let(:rand_gen_double) { double("rand_gen", rand_int: 5) }

	describe "initialize" do
		def initialize_ant_colony_tsp
			AntColonyTsp.new(edges: edge_params,
							vertices: vertex_params,
							graph_class: mock_graph_class,
							vertex_class: Graph::Vertex,
							edge_class: Graph::Edge,
							ant_class: mock_ant_class,
							rand_gen: rand_gen_double)
		end

		before(:each) do
			allow(mock_ant_class).to receive(:instances).and_return([])
		end

		it "should call initialize on provided Graph class with the correct parameters" do
			allow(mock_ant_class).to receive(:new)
			expect(mock_graph_class).to receive(:new).with(hash_including(edges: edge_params, vertices: vertex_params, vertex_class: Graph::Vertex, edge_class: Graph::Edge))
			initialize_ant_colony_tsp
		end

		it "should call initialize on provided Ant class AntColonyTsp::NUM_ANTS times" do
			allow(mock_graph_class).to receive(:new)
			expect(mock_ant_class).to receive(:new).exactly(AntColonyTsp::NUM_ANTS).times
			initialize_ant_colony_tsp
		end

		describe "testing initialization of ant class" do
			# replace mock ant class with real class
			let(:mock_ant_class) { Ant }

			it "should call initialize on provided Ant class with current_vertex set to the value provided by Utils::RandGen class" do
				allow(mock_graph_class).to receive(:new)
				initialize_ant_colony_tsp
				puts "Ant.instances = #{Ant.instances}"
				expect(Ant.instances[0].current_vertex_id).to eq(rand_gen_double.rand_int)
			end
		end
	end
end