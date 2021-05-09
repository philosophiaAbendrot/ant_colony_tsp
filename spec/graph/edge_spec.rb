require 'spec_helper'

describe Graph::Edge do
	describe "initialize" do
		let(:edge_params) { { id: 1, start_vertex_id: 5, end_vertex_id: 8, cost_of_traversal: 4.5, vertex_class: Graph::Vertex } }
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
				params = { id: id, start_vertex_id: rand(30), end_vertex_id: rand(30), cost_of_traversal: 10 * rand, vertex_class: Graph::Vertex }
				edge = Graph::Edge.new(params)
				id += 1
			end

			set_value = 7

			Graph::Edge.set_trail_densities(set_value)
			trail_densities = Graph::Edge.all.map(&:trail_density)

			expect(trail_densities.reject { |el| el == set_value }.length).to eq(0)
		end
	end

	describe "add_pheromones" do
		let(:edge_params) { { id: 1, start_vertex_id: 5, end_vertex_id: 8, cost_of_traversal: 4.5, vertex_class: Graph::Vertex } }
		let(:edge) { Graph::Edge.find(edge_params[:id]) }

		before(:each) do
			Graph::Edge.new(edge_params)
		end

		it "should update the trail density on the edge" do
			initial_density = 3
			delta_trail_density = 7

			Graph::Edge.set_trail_densities(3)

			edge.add_pheromones(delta_trail_density)
			expect(edge.delta_trail_density).to eq(delta_trail_density)
		end
	end

	describe "update_trail_densities" do
		let(:edge_params) { [{ id: 1, start_vertex_id: 5, end_vertex_id: 8, cost_of_traversal: 4.5, vertex_class: Graph::Vertex },
												{ id: 2, start_vertex_id: 3, end_vertex_id: 9, cost_of_traversal: 8.6, vertex_class: Graph::Vertex }] }
		let(:initial_density) { 3 }
		let(:trail_persistence) { 0.7 }

		before(:each) do
			edge_params.each do |edge_param|
				Graph::Edge.new(edge_param)
			end

			Graph::Edge.set_trail_densities(initial_density)
			Graph::Edge.set_trail_persistence(trail_persistence)
		end

		it "should update the trail density on the edge" do
			delta_trail_density = 4

			first_edge = Graph::Edge.find(1)
			second_edge = Graph::Edge.find(2)

			first_edge.add_pheromones(delta_trail_density)
			Graph::Edge.update_trail_densities

			expect(first_edge.trail_density).to eq(initial_density * trail_persistence + delta_trail_density)
			expect(second_edge.trail_density).to eq(initial_density * trail_persistence)
		end	

		it "should set delta_trail_density on the edge to 0" do
			delta_trail_density = 0

			first_edge = Graph::Edge.find(1)
			second_edge = Graph::Edge.find(2)

			first_edge.add_pheromones(delta_trail_density)
			Graph::Edge.update_trail_densities

			expect(first_edge.delta_trail_density).to eq(0.0)
			expect(second_edge.delta_trail_density).to eq(0.0)
		end
	end
end