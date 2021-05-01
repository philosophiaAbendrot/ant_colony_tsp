require 'spec_helper'

describe Ant do
	let(:current_vertex_id) { 5 }
	let!(:current_vertex) { Graph::Vertex.new(x_pos: -5, y_pos: 3, id: current_vertex_id) }
	let(:ant_id) { 1 }
	let(:initialize_params) { { current_vertex_id: current_vertex_id, vertex_class: Graph::Vertex, id: ant_id } }
	let(:ant) { Ant.find(ant_id) }

	before(:each) do
		Ant.new(initialize_params)
	end

	after(:each) do
		Ant.destroy_all
		Graph::Vertex.destroy_all
	end

	describe "initialize" do
		it "ant should be initialized" do
			expect(ant).to_not be nil
		end

		it "should set current vertex id to the value in the parameters" do
			expect(ant.current_vertex_id).to eq current_vertex_id
		end

		it "should initialize visited edge ids to a blank array" do
			expect(ant.visited_edge_ids).to eq []
		end

		it "should initialize visited vertex ids to a blank array" do
			expect(ant.visited_vertex_ids).to eq []
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
end