require "spec_helper"

describe AntColonyTsp do
	let(:edge_params) { [{ id: 1, start_vertex_id: 3, end_vertex_id: 4, cost_of_traversal: 5 },
											 { id: 2, start_vertex_id: 4, end_vertex_id: 3, cost_of_traversal: 3 }] }
	let(:vertex_params) { [{ id: 3, x_pos: 4, y_pos: 5 }, { id: 4, x_pos: 5.0, y_pos: 6.0 }] }
	let(:graph_class) { Graph::Graph }
	let(:vertex_class) { Graph::Vertex }
	let(:edge_class) { Graph::Edge }
	let(:ant_class) { Ant::Ant }
	let(:rand_gen_double) { class_double("Utils::RandGen") }
	let(:num_ants) { AntColonyTsp::DEFAULT_NUM_ANTS }
	let(:instance) { initialize_ant_colony_tsp }
	let(:include_edges_data) { false }
	let(:include_path_length_vs_iteration) { false }
	let(:initial_trail_density) { AntColonyTsp::INITIAL_TRAIL_DENSITY }
	let(:trail_persistence) { AntColonyTsp::RHO }

	before(:each) do
		allow(ant_class).to receive(:all).and_return(Array.new(AntColonyTsp::DEFAULT_NUM_ANTS) { double("ant_element", id: 5) })
		allow(rand_gen_double).to receive(:rand_int).and_return(vertex_params.length - 1)
	end

	after(:each) do
		Graph::Edge.destroy_all
		Graph::Vertex.destroy_all
	end
	
	def initialize_ant_colony_tsp
		AntColonyTsp.new(edge_inputs: edge_params,
						vertex_inputs: vertex_params,
						graph_class: graph_class,
						vertex_class: vertex_class,
						edge_class: edge_class,
						ant_class: ant_class,
						rand_gen: rand_gen_double,
						include_edges_data: include_edges_data,
						include_path_length_vs_iteration: include_path_length_vs_iteration)
	end

	describe "initialize" do
		describe "testing initialization of graph" do
			let(:graph_class) { class_double("Graph::Graph") }

			it "should call initialize on provided Graph class with the correct parameters" do
				instance = initialize_ant_colony_tsp
				expect(graph_class).to receive(:new).with(hash_including(edge_inputs: edge_params, vertex_inputs: vertex_params,
																																 vertex_class: vertex_class, edge_class: edge_class,
																																 initial_trail_density: initial_trail_density,
																																 trail_persistence: trail_persistence))
				instance.send(:initialize_graph)
			end
		end
	end

	describe "testing initialization of ant class" do
		# replace mock ant class with real class
		let(:ant_class) { class_double("Ant::Ant") }
		let(:ant) { Ant::Ant.all.first }

		before(:each) do
			allow(ant_class).to receive(:set_pheromone_laying_rate)
			instance.send(:initialize_graph)
		end

		it "should call initialize on provided Ant class with the correct parameters" do
			expect(ant_class).to receive(:new).exactly(num_ants).times.with(hash_including(current_vertex_id: vertex_class.all[rand_gen_double.rand_int(vertex_params.length)].id, vertex_class: Graph::Vertex))
			instance.send(:initialize_ants)
		end

		it "should call initialize on provided Ant class AntColonyTsp::NUM_ANTS times" do
			expect(ant_class).to receive(:new).exactly(num_ants).times
			instance.send(:initialize_ants)
		end
	end

	describe "testing placement of ant instances" do
		before(:each) do
			instance.send(:initialize_graph)
		end

		it "should call rand_int on Utils::RandGen class with the number of vertices currently existing" do
			expect(rand_gen_double).to receive(:rand_int).with(vertex_class.all.length)
			instance.send(:initialize_ants)
		end
	end
end