require 'spec_helper'

describe Graph::Graph do
	context "when provided with a number of edges and vertices" do
		let(:edges) { [[1, 3, 4, 5.0], [2, 4, 3, 3.0]] }
		let(:vertices) { [[3, 4.0, 5.0], [4, 5.0, 6.0]] }
		let(:mock_vertex_class) { class_double("Graph::Vertex") }
		let(:mock_edge_class) { class_double("Graph::Edge") }

		def generate_graph
			Graph::Graph.new(edges: edges, vertices: vertices, vertex_class: mock_vertex_class, edge_class: mock_edge_class)
		end

		describe "vertices should be initialized" do
			before(:each) do
				allow(mock_edge_class).to receive(:new)
			end

			# let(:first_vertex) { Graph::Vertex.find(vertices[0][0]) }
			# let(:second_vertex) { Graph::Vertex.find(vertices[1][0]) }

			it "should call Vertex.new for each vertex entry passed" do
				expect(mock_vertex_class).to receive(:new).exactly(vertices.length).times
				generate_graph
			end

			describe "vertices should be initialized with parameters in correct format" do
				let(:vertices) { [[3, 4.0, 5.0]] }

				it "vertex parameter passed should be in correct format" do
					first_vertex = vertices[0]
					expect(mock_vertex_class).to receive(:new).with(hash_including(id: first_vertex[0], x_pos: first_vertex[1], y_pos: first_vertex[2]))
					generate_graph
				end
			end

			# it "should convert each vertex input into an Vertex instance" do
			# 	expect(first_vertex).to_not be nil
			# 	expect(second_vertex).to_not be nil
			# end

			# it "should correctly set coordinates" do
			# 	expect(first_vertex.x_pos).to eq(vertices[0][1])
			# 	expect(first_vertex.y_pos).to eq(vertices[0][2])
			# 	expect(second_vertex.x_pos).to eq(vertices[1][1])
			# 	expect(second_vertex.y_pos).to eq(vertices[1][2])
			# end
		end

		describe "edges should be initialized" do
			before(:each) do
				allow(mock_vertex_class).to receive(:new)
			end

			it "should call Edge.new for each Edge entry passed" do
				expect(mock_edge_class).to receive(:new).exactly(edges.length).times
				generate_graph
			end

			describe "edges should be initialized with parameters in correct format" do
				let(:edges) { [[1, 3, 4, 5.0]] }

				it "edge parameter passed should be in correct format" do
					first_edge = edges[0]
					expect(mock_edge_class).to receive(:new).with(hash_including(id: first_edge[0], start_vertex_id: first_edge[1], end_vertex_id: first_edge[2], cost_of_traversal: first_edge[3]))
					generate_graph
				end
			end

			# let(:first_edge) { Graph::Edge.find(edges[0][0]) }
			# let(:second_edge) { Graph::Edge.find(edges[1][0]) }

			# it "should convert each edge input into an Edge instance" do
			# 	expect(first_edge).to_not be nil
			# 	expect(second_edge).to_not be nil
			# end

			# it "should correctly set start vertex id" do
				
			# end

			# it "should correctly set end vertex id" do

			# end

			# it "should correctly set cost of traversal" do

			# end

			# it "should correctly set pheromone count to 0" do

			# end
		end
	end	
end