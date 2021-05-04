require 'spec_helper'

describe Graph::Graph do
	context "when provided with a number of edges and vertices" do
		let(:edges) { [[1, 3, 4, 5.0], [2, 4, 3, 3.0]] }
		let(:vertices) { [[3, 4.0, 5.0], [4, 5.0, 6.0]] }
		let(:mock_vertex_class) { class_double("Graph::Vertex") }
		let(:mock_edge_class) { class_double("Graph::Edge") }

		def generate_graph_with_mock_classes
			Graph::Graph.new(edges_input: edges, vertices_input: vertices, vertex_class: mock_vertex_class, edge_class: mock_edge_class)
		end

		def generate_graph
			Graph::Graph.new(edges_input: edges, vertices_input: vertices, vertex_class: Graph::Vertex, edge_class: Graph::Edge)
		end

		describe "vertices should be initialized" do
			before(:each) do
				allow(mock_edge_class).to receive(:new)
			end

			it "should call Vertex.new for each vertex entry passed" do
				expect(mock_vertex_class).to receive(:new).exactly(vertices.length).times
				generate_graph_with_mock_classes
			end

			describe "vertices should be initialized with parameters in correct format" do
				let(:vertices) { [[3, 4.0, 5.0]] }

				it "vertex parameter passed should be in correct format" do
					first_vertex = vertices[0]
					expect(mock_vertex_class).to receive(:new).with(hash_including(id: first_vertex[0], x_pos: first_vertex[1], y_pos: first_vertex[2]))
					generate_graph_with_mock_classes
				end
			end
		end

		describe "edges should be initialized" do
			before(:each) do
				allow(mock_vertex_class).to receive(:new)
			end

			it "should call Edge.new for each Edge entry passed" do
				expect(mock_edge_class).to receive(:new).exactly(edges.length).times
				generate_graph_with_mock_classes
			end

			describe "edges should be initialized with parameters in correct format" do
				let(:edges) { [[1, 3, 4, 5.0]] }

				it "edge parameter passed should be in correct format" do
					first_edge = edges[0]
					expect(mock_edge_class).to receive(:new).with(hash_including(id: first_edge[0], start_vertex_id: first_edge[1], end_vertex_id: first_edge[2], cost_of_traversal: first_edge[3]))
					generate_graph_with_mock_classes
				end
			end
		end

		describe "connecting edges to vertices" do
			before(:each) do
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