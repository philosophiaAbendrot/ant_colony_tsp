require 'spec_helper'

describe Ant::VertexPreferenceGenerator do
  include GeneratorHelpers
  let(:vertex_inputs) do
    [{ id: 1, x_pos: 5.3, y_pos: 8.9 },
     { id: 2, x_pos: -8.4, y_pos: 7.2 },
     { id: 3, x_pos: -4, y_pos: -6 },
     { id: 4, x_pos: 9.5, y_pos: 5 }]
  end
  let(:edge_inputs) do
    [{ id: 1, cost_of_traversal: 4.6, start_vertex_id: 1, end_vertex_id: 3 },
     { id: 2, cost_of_traversal: 9.5, start_vertex_id: 1, end_vertex_id: 4 },
     { id: 3, cost_of_traversal: 7.3, start_vertex_id: 1, end_vertex_id: 2 }]
  end

  let(:default_pheromone_density) { 3 }
  let(:config) { Config.new }

  before(:each) do
    generate_vertices(vertex_inputs)
    generate_edges(edge_inputs, default_pheromone_density)
  end

  after(:each) do
    Graph::Vertex.destroy_all
    Graph::Edge.destroy_all
  end

  context 'when none of the vertices have been visited (except the current vertex)' do
    let(:visited_vertex_ids) { [1] }

    it 'should provide a mapping of vertex ids to preference value' do
      edge_1 = Graph::Edge.find(1)
      tau_1_3 = edge_1.trail_density**config.alpha
      eta_1_3 = (1 / edge_1.cost_of_traversal)**config.beta

      edge_2 = Graph::Edge.find(2)
      tau_1_4 = edge_2.trail_density**config.alpha
      eta_1_4 = (1 / edge_2.cost_of_traversal)**config.beta

      edge_3 = Graph::Edge.find(3)
      tau_1_2 = edge_3.trail_density**config.alpha
      eta_1_2 = (1 / edge_3.cost_of_traversal)**config.beta

      sum = (tau_1_3 * eta_1_3 + tau_1_4 * eta_1_4 + tau_1_2 * eta_1_2).to_f

      hashed_result = { edge_1.end_vertex_id => tau_1_3 * eta_1_3 / sum, edge_2.end_vertex_id => tau_1_4 * eta_1_4 / sum,
                        edge_3.end_vertex_id => tau_1_2 * eta_1_2 / sum }
      cumulative_probability_mapping = []
      cumulative_prob = 0
      cumulative_prob += hashed_result[edge_1.end_vertex_id]
      cumulative_probability_mapping << [edge_1.end_vertex_id, cumulative_prob]

      cumulative_prob += hashed_result[edge_2.end_vertex_id]
      cumulative_probability_mapping << [edge_2.end_vertex_id, cumulative_prob]

      cumulative_prob += hashed_result[edge_3.end_vertex_id]
      cumulative_probability_mapping << [edge_3.end_vertex_id, cumulative_prob]

      result = Ant::VertexPreferenceGenerator.execute(visited_vertex_ids: visited_vertex_ids,
                                                      outgoing_edges: Graph::Edge.all, alpha: config.alpha, beta: config.beta)
      expect(compare_array_of_floats(result, cumulative_probability_mapping)).to be true
    end
  end

  context 'when some vertices have been visited' do
    let(:visited_vertex_ids) { [1, 3] }

    it 'should provided a mapping of vertex ids to preference value' do
      edge_2 = Graph::Edge.find(2)
      tau_1_4 = edge_2.trail_density**config.alpha
      eta_1_4 = (1 / edge_2.cost_of_traversal)**config.beta
      product_1_4 = tau_1_4 * eta_1_4

      edge_3 = Graph::Edge.find(3)
      tau_1_2 = edge_3.trail_density**config.alpha
      eta_1_2 = (1 / edge_3.cost_of_traversal)**config.beta
      product_1_2 = tau_1_2 * eta_1_2

      sum = (product_1_4 + product_1_2).to_f

      hashed_result = { edge_2.end_vertex_id => tau_1_4 * eta_1_4 / sum,
                        edge_3.end_vertex_id => tau_1_2 * eta_1_2 / sum }
      cumulative_probability_mapping = []
      cumulative_prob = 0

      cumulative_prob += hashed_result[edge_2.end_vertex_id]
      cumulative_probability_mapping << [edge_2.end_vertex_id, cumulative_prob]

      cumulative_prob += hashed_result[edge_3.end_vertex_id]
      cumulative_probability_mapping << [edge_3.end_vertex_id, cumulative_prob]

      result = Ant::VertexPreferenceGenerator.execute(visited_vertex_ids: visited_vertex_ids,
                                                      outgoing_edges: Graph::Edge.all, alpha: config.alpha, beta: config.beta)
      expect(compare_array_of_floats(result, cumulative_probability_mapping)).to be true
    end
  end

  context 'when all vertices have been visited' do
    let(:visited_vertex_ids) { [1, 2, 3, 4] }

    it 'should return an empty array' do
      result = Ant::VertexPreferenceGenerator.execute(visited_vertex_ids: visited_vertex_ids,
                                                      outgoing_edges: Graph::Edge.all, alpha: config.alpha, beta: config.beta)
      expect(result).to eq([])
    end
  end

  private

  def compare_array_of_floats(arr1, arr2)
    return false if arr1.length != arr2.length

    (0..arr1.length - 1).each do |i|
      sub_arr1 = arr1[i]
      sub_arr2 = arr2[i]

      return false unless sub_arr1.length == sub_arr2.length

      return false unless compare_floats(arr1[i][0], arr2[i][0]) && compare_floats(arr1[i][1], arr2[i][1])
    end

    true
  end

  def compare_floats(float1, float2)
    # if percent difference is < 0.1%, pass
    diff = (float1 - float2).abs
    average = (float1 + float2) / 2.0
    percent_diff = diff / average * 100
    percent_diff < 0.1
  end
end
