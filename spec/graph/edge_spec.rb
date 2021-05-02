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
	end

	describe "set_trail_densities" do
		it "should set trail densities to a set value for all edges" do
			id = 1	
			20.times do
				params = { id: id, start_vertex_id: rand(30), end_vertex_id: rand(30), cost_of_traversal: 10 * rand }
				edge = Graph::Edge.new(params)
				id += 1
			end

			set_value = 7

			Graph::Edge.set_trail_densities(set_value)
			trail_densities = Graph::Edge.all.map(&:trail_density)

			expect(trail_densities.reject { |el| el == set_value }.length).to eq(0)
		end
	end

	describe "initialize_delta_trail_densities" do
		it "should set delta trail densities to 0 for all edges" do
			id = 1

			20.times do
				params = { id: id, start_vertex_id: rand(30), end_vertex_id: rand(30), cost_of_traversal: 10 * rand }
				edge = Graph::Edge.new(params)
				edge.delta_trail_density = 3
				id += 1
			end

			Graph::Edge.initialize_delta_trail_densities
			trail_densities = Graph::Edge.all.map(&:delta_trail_density)
			expect(trail_densities.reject { |el| el == 0 }.length).to eq(0)
		end
	end
end