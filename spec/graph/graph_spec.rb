require 'spec_helper'

describe Graph::Graph do
	context "when provided with a number of edges and vertices" do
		let(:edge_params) { [{ id: 1, start_vertex_id: 3, end_vertex_id: 4, cost_of_traversal: 5 },
											 { id: 2, start_vertex_id: 4, end_vertex_id: 3, cost_of_traversal: 3 }] }
		let(:vertex_params) { [{ id: 3, x_pos: 4, y_pos: 5 }, { id: 4, x_pos: 5.0, y_pos: 6.0 }] }
		let(:mock_vertex_class) { class_double("Graph::Vertex") }
		let(:mock_edge_class) { class_double("Graph::Edge") }
		let(:mock_vertex_instance_3) { double("vertex_3", outgoing_edge_ids: [], incoming_edge_ids: []) }
		let(:mock_vertex_instance_4) { double("vertex_4", outgoing_edge_ids: [], incoming_edge_ids: []) }
		let(:mock_edge_instance_1) { double("edge_1", id: 1, start_vertex_id: 3, end_vertex_id: 4, start_vertex: mock_vertex_instance_3, end_vertex: mock_vertex_instance_4) }
		let(:mock_edge_instance_2) { double("edge_2", id: 2, start_vertex_id: 4, end_vertex_id: 3, start_vertex: mock_vertex_instance_4, end_vertex: mock_vertex_instance_3) }
		let(:initial_trail_density) { 5 }

		def generate_graph_with_mock_classes
			Graph::Graph.new(edges_input: edge_params, vertices_input: vertex_params, vertex_class: mock_vertex_class, edge_class: mock_edge_class, initial_trail_density: initial_trail_density)
		end

		def generate_graph
			Graph::Graph.new(edges_input: edge_params, vertices_input: vertex_params, vertex_class: Graph::Vertex, edge_class: Graph::Edge, initial_trail_density: initial_trail_density)
		end

		before(:each) do
		  Graph::Vertex.destroy_all
			Graph::Edge.destroy_all
			allow(mock_edge_class).to receive(:find).with(1).and_return(mock_edge_instance_1)
			allow(mock_edge_class).to receive(:find).with(2).and_return(mock_edge_instance_2)
			allow(mock_edge_class).to receive(:all).and_return([mock_edge_instance_1, mock_edge_instance_2])
			allow(mock_edge_class).to receive(:set_trail_densities)
		end

		describe "vertices should be initialized" do
			before(:each) do
				allow(mock_edge_class).to receive(:new)
			end

			it "should call Vertex.new for each vertex entry passed" do
				expect(mock_vertex_class).to receive(:new).exactly(vertex_params.length).times
				generate_graph_with_mock_classes
			end

			describe "vertices should be initialized with parameters in correct format" do
				let(:vertex_params) { [{ id: 3, x_pos: 4.0, y_pos: 5.0 }] }

				it "vertex parameter passed should be in correct format" do
					first_vertex = vertex_params[0]
					expect(mock_vertex_class).to receive(:new).with(hash_including(id: first_vertex[:id], x_pos: first_vertex[:x_pos], y_pos: first_vertex[:y_pos]))
					generate_graph_with_mock_classes
				end
			end
		end

		describe "edges should be initialized" do
			before(:each) do
				allow(mock_vertex_class).to receive(:new)
			end

			it "should call Edge.new for each Edge entry passed" do
				expect(mock_edge_class).to receive(:new).exactly(edge_params.length).times
				generate_graph_with_mock_classes
			end

			describe "edges should be initialized with parameters in correct format" do
				let(:edge_params) { [{ id: 1, start_vertex_id: 3, end_vertex_id: 4, cost_of_traversal: 5 }] }

				it "edge parameter passed should be in correct format" do
					first_edge = edge_params[0]
					expect(mock_edge_class).to receive(:new).with(hash_including(id: first_edge[:id], start_vertex_id: first_edge[:start_vertex_id], end_vertex_id: first_edge[:end_vertex_id], cost_of_traversal: first_edge[:cost_of_traversal]))
					generate_graph_with_mock_classes
				end
			end
		end

		describe "connecting edges to vertices" do
			before(:each) do
				Graph::Vertex.destroy_all
				Graph::Edge.destroy_all
				generate_graph
			end

			it "outgoing edge ids should be populated" do
				vertex_3 = Graph::Vertex.find(3)
				vertex_4 = Graph::Vertex.find(4)

				expect(vertex_3.outgoing_edge_ids).to eq([1])
				expect(vertex_4.outgoing_edge_ids).to eq([2])
			end

			it "incoming edge ids should be populated" do
				vertex_3 = Graph::Vertex.find(3)
				vertex_4 = Graph::Vertex.find(4)

				expect(vertex_3.incoming_edge_ids).to eq([2])
				expect(vertex_4.incoming_edge_ids).to eq([1])
			end
		end
	end	
end