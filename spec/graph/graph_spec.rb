require 'spec_helper'

describe Graph::Graph do
	context "when provided with a number of edges and vertices" do
		let(:edges) { [[1, 3, 4, 5.0], [2, 4, 3, 3.0]] }
		let(:vertices) { [[3, 4.0, 5.0], [4, 5.0, 6.0]] }

		before(:each) do
			Graph::Graph.new(edges: edges, vertices: vertices)
		end

		after(:each) do
			Graph::Edge.destroy_all
			Graph::Vertex.destroy_all
		end

		describe "vertices should be generated" do
			let(:first_vertex) { Graph::Vertex.find(vertices[0][0]) }
			let(:second_vertex) { Graph::Vertex.find(vertices[1][0]) }

			it "should convert each vertex input into an Vertex instance" do
				expect(first_vertex).to_not be nil
				expect(second_vertex).to_not be nil
			end

			it "should correctly set coordinates" do
				expect(first_vertex.x_pos).to eq(vertices[0][1])
				expect(first_vertex.y_pos).to eq(vertices[0][2])
				expect(second_vertex.x_pos).to eq(vertices[1][1])
				expect(second_vertex.y_pos).to eq(vertices[1][2])
			end
		end

		describe "edges should be generated" do
			let(:first_edge) { Graph::Edge.find(edges[0][0]) }
			let(:second_edge) { Graph::Edge.find(edges[1][0]) }

			it "should convert each edge input into an Edge instance" do
				expect(first_edge).to_not be nil
				expect(second_edge).to_not be nil
			end

			it "should correctly set start vertex id" do
				
			end

			it "should correctly set end vertex id" do

			end

			it "should correctly set cost of traversal" do

			end

			it "should correctly set pheromone count to 0" do

			end
		end
	end	
end