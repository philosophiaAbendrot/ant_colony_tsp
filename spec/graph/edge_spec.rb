require 'spec_helper'

describe Graph::Edge do
	describe "initialize" do
		let(:edge_params) { { id: 1, start_vertex_id: 5, end_vertex_id: 8, cost_of_traversal: 4.5 } }
		let(:edge) { Graph::Edge.find(edge_params[:id]) }

		before(:each) do
			Graph::Edge.new(edge_params)
		end

		it "should initialize an edge instance" do
			expect(edge).to_not be nil
		end

		it "should correctly set start vertex id" do
			expect(edge.start_vertex_id).to eq(edge_params[:start_vertex_id])
		end

		it "should correctly set end vertex id" do
			expect(edge.end_vertex_id).to eq(edge_params[:end_vertex_id])
		end

		it "should correctly set cost of traversal" do
			expect(edge.cost_of_traversal).to eq(edge_params[:cost_of_traversal])
		end

		it "should correctly set pheromone count to 0" do
			expect(edge.pheromone_count).to eq(0)
		end
	end	
end