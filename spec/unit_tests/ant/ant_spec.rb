# frozen_string_literal: true

require 'spec_helper'

describe Ant::Ant do
  include GeneratorHelpers

  let(:current_vertex_id) { 5 }
  let!(:current_vertex) { Graph::Vertex.new(x_pos: -5, y_pos: 3, id: current_vertex_id) }
  let(:ant_id) { 1 }
  let(:config) { Config.new.process_configs }
  let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }

  before do
    Ant::Ant.set_config(config)
  end

  after do
    Ant::Ant.destroy_all
  end

  describe '#initialize' do
    subject(:ant) do
      Ant::Ant.set_config(config)
      Ant::Ant.new(initialize_params)
    end

    it { is_expected.not_to be nil }

    it 'sets current vertex id to the value in the parameters' do
      expect(ant.current_vertex_id).to eq current_vertex_id
    end

    it 'initializes visited edge ids to be a blank array' do
      expect(ant.visited_edge_ids).to eq []
    end

    it 'initializes visited vertex ids to an array that includes just'\
       'the current_vertex_id' do
      expect(ant.visited_vertex_ids).to eq [current_vertex_id]
    end
  end

  describe '#current_vertex' do
    subject(:ant) do
      Ant::Ant.new(initialize_params)
    end

    it 'should return the vertex associated with the Ant instance' do
      expect(ant.current_vertex).to eq current_vertex
    end
  end

  describe '#x_pos' do
    subject(:ant) do
      Ant::Ant.new(initialize_params)
    end

    it 'should return the x_pos of the current_vertex' do
      expect(ant.x_pos).to eq current_vertex.x_pos
    end
  end

  describe '#y_pos' do
    subject(:ant) do
      Ant::Ant.new(initialize_params)
    end

    it 'should return the y_pos of the current_vertex' do
      expect(ant.y_pos).to eq current_vertex.y_pos
    end
  end

  describe '#move_to_next_vertex' do
    let(:vertex1) do
      instance_double(
        Graph::Vertex, id: 1, x_pos: 5.3, y_pos: 8.9,
        outgoing_edge_ids: [1, 2, 3]
      )
    end
    let(:vertex2) do
      instance_double(Graph::Vertex, id: 2, x_pos: -8.4, y_pos: 7.2)
    end
    let(:vertex3) do
      instance_double(Graph::Vertex, id: 3, x_pos: -4, y_pos: -6)
    end
    let(:vertex4) do
      instance_double(Graph::Vertex, id: 4, x_pos: 9.5, y_pos: 5)
    end
    let(:vertex_class) { class_double(Graph::Vertex, destroy_all: nil) }

    let(:edge1) do
      instance_double(
        Graph::Edge,
        id: 1, cost_of_traversal: 4.6,
        start_vertex_id: 1, end_vertex_id: 3
      )
    end
    let(:edge2) do
      instance_double(
        Graph::Edge,
        id: 2, cost_of_traversal: 9.5,
        start_vertex_id: 1, end_vertex_id: 4
      )
    end
    let(:edge3) do
      instance_double(
        Graph::Edge,
        id: 3, cost_of_traversal: 7.3,
        start_vertex_id: 1, end_vertex_id: 2
      )
    end
    let(:edge_class) { class_double(Graph::Edge, destroy_all: nil) }

    let(:next_vertex_id) { 2 }
    let(:preferences_are_empty) { false }
    let(:vertex_pref_inst) do
      instance_double(
        Ant::VertexPreferences,
        select_rand_vertex: next_vertex_id,
        empty?:             preferences_are_empty
      )
    end
    let(:vertex_pref_class) do
      class_double(
        Ant::VertexPreferences,
        new: vertex_pref_inst
      )
    end
    let(:current_vertex_id) { 1 }
    let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }
    subject(:ant) do
      config.process_configs
      Ant::Ant.set_config(config)
      Ant::Ant.new(initialize_params).tap do |ant|
        ant.current_vertex_id  = current_vertex_id
        ant.visited_vertex_ids = [current_vertex_id]
      end
    end
    let(:edge_class) { class_double(Graph::Edge) }

    before(:each) do
      allow(edge_class).to receive(:find).with(1).and_return(edge1)
      allow(edge_class).to receive(:find).with(2).and_return(edge2)
      allow(edge_class).to receive(:find).with(3).and_return(edge3)
      stub_const('Graph::Edge', edge_class)

      allow(vertex_class).to receive(:find).with(1).and_return(vertex1)
      allow(vertex_class).to receive(:find).with(2).and_return(vertex2)
      allow(vertex_class).to receive(:find).with(3).and_return(vertex3)
      allow(vertex_class).to receive(:find).with(4).and_return(vertex4)
      stub_const('Graph::Vertex', vertex_class)

      stub_const('Ant::VertexPreferences', vertex_pref_class)
    end

    it 'moves to the correct vertex' do
      # calculate what answer should be
      # edge_1 = Graph::Edge.find(1)
      # tau_1_3 = (edge_1.trail_density)**AntColonyTsp::ALPHA_VALUE
      # eta_1_3 = (1 / edge_1.cost_of_traversal)**AntColonyTsp::BETA_VALUE

      # edge_2 = Graph::Edge.find(2)
      # tau_1_4 = (edge_2.trail_density)**AntColonyTsp::ALPHA_VALUE
      # eta_1_4 = (1 / edge_2.cost_of_traversal)**AntColonyTsp::BETA_VALUE

      # edge_3 = Graph::Edge.find(3)
      # tau_1_2 = (edge_3.trail_density)**AntColonyTsp::ALPHA_VALUE
      # eta_1_2 = (1 / edge_3.cost_of_traversal)**AntColonyTsp::BETA_VALUE

      # sum = (tau_1_3 * eta_1_3 + tau_1_4 * eta_1_4 + tau_1_2 * eta_1_2).to_f

      # hashed_result = { edge_1.end_vertex_id => tau_1_3 * eta_1_3 / sum, edge_2.end_vertex_id => tau_1_4 * eta_1_4 / sum, edge_3.end_vertex_id => tau_1_2 * eta_1_2 / sum }
      # cumulative_probability_mapping = []
      # cumulative_prob = 0
      # cumulative_prob += hashed_result[edge_1.end_vertex_id]
      # cumulative_probability_mapping << [edge_1.end_vertex_id, cumulative_prob]

      # cumulative_prob += hashed_result[edge_2.end_vertex_id]
      # cumulative_probability_mapping << [edge_2.end_vertex_id, cumulative_prob]

      # cumulative_prob += hashed_result[edge_3.end_vertex_id]
      # cumulative_probability_mapping << [edge_3.end_vertex_id, cumulative_prob]
      ant.move_to_next_vertex
      expect(ant.current_vertex_id).to eq(next_vertex_id)
    end

    it 'returns true to indicate that the ant moved successfully' do
      expect(ant.move_to_next_vertex).to be true
    end

    it 'has new vertex in its list of visited vertices' do
      ant.move_to_next_vertex
      expect(ant.visited_vertex_ids).to include(next_vertex_id)
    end

    it 'should have start vertex in its list of visited edges' do
      ant.move_to_next_vertex
      expect(ant.visited_edge_ids).to include(3)
    end

    context 'if there is no unvisited adjacent vertex' do
      let(:preferences_are_empty) { true }

      before(:each) do
        ant.visited_vertex_ids = [2, 3, 4]
      end

      it 'ant should not move' do
        ant.move_to_next_vertex
        expect(ant.current_vertex_id).to eq(current_vertex_id)
      end

      it 'should return false to indicate that ant did not move' do
        ant.move_to_next_vertex
        expect(ant.move_to_next_vertex).to be false
      end
    end
  end

  describe '#move_to_start' do
    let(:vertex1) do
      instance_double(
        Graph::Vertex, id: 1, x_pos: 5.3, y_pos: 8.9,
        outgoing_edge_ids: [1]
      )
    end
    let(:vertex2) do
      instance_double(
        Graph::Vertex, id: 2, x_pos: -8.4, y_pos: 7.2,
        outgoing_edge_ids: [2]
      )
    end
    let(:vertex3) do
      instance_double(
        Graph::Vertex, id: 3, x_pos: -4, y_pos: -6,
        outgoing_edge_ids: [3, 4]
      )
    end
    let(:vertex_class) { class_double(Graph::Vertex, destroy_all: nil) }

    let(:edge1) do
      instance_double(
        Graph::Edge,
        id: 1, cost_of_traversal: 4.6,
        start_vertex_id: 1, end_vertex_id: 2
      )
    end
    let(:edge2) do
      instance_double(
        Graph::Edge,
        id: 2, cost_of_traversal: 9.5,
        start_vertex_id: 2, end_vertex_id: 3
      )
    end
    let(:edge3) do
      instance_double(
        Graph::Edge,
        id: 3, cost_of_traversal: 7.3,
        start_vertex_id: 3, end_vertex_id: 1
      )
    end
    let(:edge4) do
      instance_double(
        Graph::Edge,
        id: 4, cost_of_traversal: 4.0,
        start_vertex_id: 3, end_vertex_id: 2
      )
    end
    let(:edge_class) { class_double(Graph::Edge, destroy_all: nil) }

    let(:edge_which_connects_to_first_vertex) { 3 }
    let(:current_vertex_id)                   { 3 }
    let(:start_vertex_id)                     { 1 }
    let(:visited_vertex_ids)                  { [1, 2, 3] }
    let(:visited_edge_ids)                    { [1, 2] }

    subject(:ant) do
      Ant::Ant.new(current_vertex_id: current_vertex_id, id: ant_id).tap do |ant|
        ant.visited_vertex_ids = visited_vertex_ids
        ant.visited_edge_ids   = visited_edge_ids
      end
    end

    before do
      allow(vertex_class).to receive(:find).with(1).and_return(vertex1)
      allow(vertex_class).to receive(:find).with(2).and_return(vertex2)
      allow(vertex_class).to receive(:find).with(3).and_return(vertex3)

      allow(edge_class).to receive(:find).with(1).and_return(edge1)
      allow(edge_class).to receive(:find).with(2).and_return(edge2)
      allow(edge_class).to receive(:find).with(3).and_return(edge3)
      allow(edge_class).to receive(:find).with(4).and_return(edge4)

      stub_const('Graph::Vertex', vertex_class)
      stub_const('Graph::Edge', edge_class)
    end

    it 'should move to the correct vertex' do
      ant.move_to_start
      expect(ant.current_vertex_id).to eq(start_vertex_id)
    end

    it 'should return true to indicate that the ant moved successfully' do
      expect(ant.move_to_start).to be true
    end

    it 'should have the first vertex twice in its list of visited vertices' do
      ant.move_to_start
      expect(ant.visited_vertex_ids[0]).to eq(ant.visited_vertex_ids[-1])
    end

    it 'should have the edge that connects the last vertex to the first'\
       'vertex in its list of visited edges' do
      ant.move_to_start
      expect(ant.visited_edge_ids[-1]).to eq(
        edge_which_connects_to_first_vertex
      )
    end

    context 'if there is no connected vertex which has not been visited' do
      let(:edge3) { nil }
      let(:vertex3) do
        instance_double(
          Graph::Vertex, id: 3, x_pos: -4, y_pos: -6,
          outgoing_edge_ids: [4]
        )
      end

      it 'ant should not move' do
        ant.move_to_start
        expect(ant.current_vertex_id).to eq(current_vertex_id)
      end

      it 'should not change visited vertex ids' do
        ant.move_to_start
        expect(ant.visited_vertex_ids).to eq(visited_vertex_ids)
      end

      it 'should not change visited edge ids' do
        ant.move_to_start
        expect(ant.visited_edge_ids).to eq(visited_edge_ids)
      end

      it 'should return false to indicate that the ant did not move' do
        expect(ant.move_to_start).to be false
      end
    end
  end

  describe '#find_path_length' do
    let(:edge1) do
      instance_double(
        Graph::Edge, id: 1, cost_of_traversal: 5.3,
        start_vertex_id: 1, end_vertex_id: 2
      )
    end
    let(:edge2) do
      instance_double(
        Graph::Edge, id: 2, cost_of_traversal: 7.0,
        start_vertex_id: 2, end_vertex_id: 3
      )
    end
    let(:edge3) do
      instance_double(
        Graph::Edge, id: 3, cost_of_traversal: 1.1,
        start_vertex_id: 3, end_vertex_id: 1
      )
    end
    let(:edge_class) { class_double('Graph::Edge') }
    let(:current_vertex_id)  { 1 }
    let(:ant_id)             { 1 }
    let(:visited_edge_ids)   { [1, 2, 3] }

    before do
      stub_const('Graph::Edge', edge_class)

      allow(edge_class).to receive(:find).with(1).and_return(edge1)
      allow(edge_class).to receive(:find).with(2).and_return(edge2)
      allow(edge_class).to receive(:find).with(3).and_return(edge3)
    end

    subject(:ant) do
      Ant::Ant.new(
        current_vertex_id: current_vertex_id, id: ant_id
      ).tap do |ant|
        ant.visited_edge_ids = visited_edge_ids
      end
    end

    it 'should return the correct path length' do
      expected_length = [edge1, edge2, edge3].reduce(0) do |sum, edge|
        sum + edge.cost_of_traversal
      end
      expect(ant.find_path_length).to eq(expected_length)
    end
  end

  describe 'lay_phermones' do
    let(:edge_inputs) do
      [{ id: 1, cost_of_traversal: 5.3, start_vertex_id: 1, end_vertex_id: 2 },
       { id: 2, cost_of_traversal: 7.0, start_vertex_id: 2, end_vertex_id: 3 },
       { id: 3, cost_of_traversal: 1.1, start_vertex_id: 3, end_vertex_id: 1 }]
    end
    let(:edge1) do
      instance_double('edge1', id: 1, cost_of_traversal: 5.3,
                      start_vertex_id: 1, end_vertex_id: 2)
    end
    let(:edge2) do
      instance_double('edge2', id: 2, cost_of_traversal: 7.0,
                      start_vertex_id: 2, end_vertex_id: 3)
    end
    let(:edge3) do
      instance_double('edge3', id: 3, cost_of_traversal: 1.1,
                      start_vertex_id: 3, end_vertex_id: 1)
    end
    let(:edge_class) { class_double('Graph::Edge') }
    
    let(:q) { 5 }
    let(:visited_edge_ids)   { [1, 2, 3] }
    let(:visited_vertex_ids) { [1, 2, 3] }

    before do
      stub_const('Graph::Edge', edge_class)

      config.q = q
      config.process_configs
      Ant::Ant.set_config(config)

      allow(edge_class).to receive(:find).with(1).and_return(edge1)
      allow(edge_class).to receive(:find).with(2).and_return(edge2)
      allow(edge_class).to receive(:find).with(3).and_return(edge3)
    end

    subject(:ant) do
      Ant::Ant.new(
        current_vertex_id: current_vertex_id, id: ant_id
      ).tap do |ant|
        ant.visited_vertex_ids = visited_vertex_ids
        ant.visited_edge_ids   = visited_edge_ids
      end
    end

    it 'should call add_pheromones with delta value Q/Lk on each edge' do
      path_length = [edge1, edge2, edge3].reduce(0) do |sum, edge|
        sum + edge.cost_of_traversal
      end
      expected_density = q.to_f / path_length
      expect(edge1).to receive(:add_pheromones).with(expected_density)
      expect(edge2).to receive(:add_pheromones).with(expected_density)
      expect(edge3).to receive(:add_pheromones).with(expected_density)
      ant.lay_pheromones
    end
  end

  describe 'reset_to_original_position' do
    let(:vertex_inputs) do
      [{ id: 1, x_pos: 5.3, y_pos: 8.9 }, { id: 2, x_pos: -8.4, y_pos: 7.2 }, { id: 3, x_pos: -4, y_pos: -6 }]
    end
    let(:edge_inputs) do
      [{ id: 1, cost_of_traversal: 5.3, start_vertex_id: 1, end_vertex_id: 2 },
       { id: 2, cost_of_traversal: 7.0, start_vertex_id: 2, end_vertex_id: 3 },
       { id: 3, cost_of_traversal: 1.1, start_vertex_id: 3, end_vertex_id: 1 }]
    end
    let(:initialize_params) { { current_vertex_id: current_vertex_id, id: ant_id } }

    before(:each) do
      generate_vertices(vertex_inputs)
      generate_edges(edge_inputs, config.initial_trail_density)

      Ant::Ant.new(initialize_params)

      # set up connections on the vertex the ant is on
      vertex_1 = Graph::Vertex.find(1)
      vertex_1.outgoing_edge_ids = [1, 2, 3]

      ant.current_vertex_id = 3
      ant.visited_vertex_ids = [1, 2, 3]
      ant.visited_edge_ids = [1, 2, 3]
    end

    it 'should clear visited edge ids' do
      Ant::Ant.reset_to_original_position
      expect(ant.visited_edge_ids).to eq([])
    end

    it 'should clear visited vertex ids' do
      original_vertex_id = ant.visited_vertex_ids[0]
      Ant::Ant.reset_to_original_position
      expect(ant.visited_vertex_ids).to eq([original_vertex_id])
    end

    it 'should place ant in the original position' do
      original_vertex_id = ant.visited_vertex_ids[0]
      Ant::Ant.reset_to_original_position
      expect(ant.current_vertex_id).to eq(original_vertex_id)
    end
  end
end
