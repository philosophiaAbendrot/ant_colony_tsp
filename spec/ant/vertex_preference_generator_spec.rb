require "spec_helper"

describe Ant::VertexPreferenceGenerator do
	# vertices input format: [id, x_pos, y_pos]
	let(:vertex_inputs) { [[1, 5.3, 8.9 ], [2, -8.4, 7.2], [3, -4, -6], [4, 9.5, 5]] }
	# edges input format: [id, cost_of_traversal, start_vertex_id, end_vertex_id]
	let(:edge_inputs) { [[1, 4.6, 1, 3], [2, 9.5, 1, 4], [3, 7.3, 1, 2], [4, 1.1, 2, 4]] }
	let(:default_pheromone_density) { 3 }

	def generate_vertices
		vertex_inputs.each do |input|
			Graph::Vertex.new(id: input[0], x_pos: input[1], y_pos: input[2])
		end
	end

	def generate_edges
		edge_inputs.each do |input|
			edge = Graph::Edge.new(id: input[0], cost_of_traversal: input[1], start_vertex_id: input[2], end_vertex_id: input[3])
			edge.trail_density = default_pheromone_density
		end
	end

	before(:each) do
		generate_vertices
		generate_edges
	end

	after(:each) do
		Graph::Vertex.destroy_all
		Graph::Edge.destroy_all
	end

	context "when none of the vertices have been visited" do
		it "should provide a mapping of vertex ids to preference value" do
			edge_1 = Graph::Edge.find(1)
			tau_1_3 = edge_1.trail_density
			eta_1_3 = edge_1.cost_of_traversal

			edge_2 = Graph::Edge.find(2)
			tau_1_4 = edge_2.trail_density
			eta_1_4 = edge_2.cost_of_traversal

			edge_3 = Graph::Edge.find(3)
			tau_1_2 = edge_3.trail_density
			eta_1_2 = edge_2.cost_of_traversal

			sum = tau_1_4 * eta_1_3 + tau_1_4 * eta_1_4 + tau_1_2 * eta_1_2

			expected_result = { edge_1.end_vertex_id => tau_1_3 * eta_1_3 / sum, edge_2.end_vertex_id => tau_1_4 * eta_1_4 / sum, edge_3.end_vertex_id => tau_1_2 * eta_1_2 / sum }

			result = Ant::VertexPreferenceGenerator.execute(current_vertex: Graph::Vertex.find(1), outgoing_edges: Graph::Edge.all)
			expect(result).to eq(expected_result)
		end
	end
end