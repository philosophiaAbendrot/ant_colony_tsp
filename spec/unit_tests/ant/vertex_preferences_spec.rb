# frozen_string_literal: true

require 'spec_helper'

describe Ant::VertexPreferences do
  include GeneratorHelpers

  let(:vertex1) do
    instance_double(Graph::Vertex, id: 1, x_pos: 5.3, y_pos: 8.9)
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
  let(:vertex_class) do
    class_double('Graph::Vertex')
  end

  let(:edge1) do
    instance_double(
      Graph::Edge, id: 1, cost_of_traversal: 4.6,
      start_vertex_id: 1, end_vertex_id: 3,
      trail_density: 0.3
    )
  end
  let(:edge2) do
    instance_double(
      Graph::Edge, id: 2, cost_of_traversal: 9.5,
      start_vertex_id: 1, end_vertex_id: 4,
      trail_density: 0.12
    )
  end
  let(:edge3) do
    instance_double(
      Graph::Edge, id: 3, cost_of_traversal: 7.3,
      start_vertex_id: 1, end_vertex_id: 2,
      trail_density: 0.54
    )
  end
  let(:edge_class) do
    class_double('Graph::Edge')
  end

  let(:default_pheromone_density) { 3 }
  let(:config) { Config.new }
  let(:fixed_rand_value) { 0.7 }

  let(:preference) do
    described_class.new(
      visited_vertex_ids: visited_vertex_ids,
      outgoing_edges:     [edge1, edge2, edge3],
      alpha:              config.alpha,
      beta:               config.beta
    )
  end

  before do
    allow(vertex_class).to receive(:find).with(1).and_return(vertex1)
    allow(vertex_class).to receive(:find).with(2).and_return(vertex2)
    allow(vertex_class).to receive(:find).with(3).and_return(vertex3)
    allow(vertex_class).to receive(:find).with(4).and_return(vertex4)
    stub_const('Graph::Vertex', vertex_class)

    allow(edge_class).to receive(:find).with(1).and_return(edge1)
    allow(edge_class).to receive(:find).with(2).and_return(edge2)
    allow(edge_class).to receive(:find).with(3).and_return(edge3)
    stub_const('Graph::Edge', edge_class)

    allow(preference).to receive(:rand).and_return(fixed_rand_value)
  end

  describe '#select_rand_vertex' do
    subject(:selected_vertex) do
      preference.select_rand_vertex
    end

    context 'when none of the vertices have been visited'\
            '(except the current vertex)' do
      let(:visited_vertex_ids) { [1] }

      context 'when rand returns 0.7' do
        let(:fixed_rand_value) { 0.7 }

        it { is_expected.to eq(2) }
      end

      context 'when rand returns 0.4' do
        let(:fixed_rand_value) { 0.5 }

        it { is_expected.to eq(4) }
      end

      context 'when rand returns 0.1' do
        let(:fixed_rand_value) { 0.3 }

        it { is_expected.to eq(3) }
      end
    end

    context 'when some vertices have been visited' do
      let(:visited_vertex_ids) { [1, 3] }

      context 'when rand returns 0.7' do
        let(:fixed_rand_value) { 0.7 }

        it { is_expected.to eq 2 }
      end

      context 'when rand returns 0.4' do
        let(:fixed_rand_value) { 0.4 }

        it { is_expected.to eq 2 }
      end

      context 'when rand returns 0.1' do
        let(:fixed_rand_value) { 0.1 }

        it { is_expected.to eq 4 }
      end
    end

    context 'when all vertices have been visited' do
      let(:visited_vertex_ids) { [1, 2, 3, 4] }

      context 'when rand returns 0.7' do
        let(:fixed_rand_value) { 0.7 }

        it { is_expected.to be nil }
      end

      context 'when rand returns 0.4' do
        let(:fixed_rand_value) { 0.4 }

        it { is_expected.to be nil }
      end

      context 'when rand returns 0.1' do
        let(:fixed_rand_value) { 0.1 }

        it { is_expected.to be nil }
      end
    end
  end

  describe '#empty?' do
    subject { preference.empty? }

    context 'when all vertices have been visited' do
      let(:visited_vertex_ids) { [1, 2, 3, 4] }

      context 'when rand returns 0.7' do
        let(:fixed_rand_value) { 0.7 }

        it { is_expected.to be true }
      end

      context 'when rand returns 0.4' do
        let(:fixed_rand_value) { 0.4 }

        it { is_expected.to be true }
      end

      context 'when rand returns 0.1' do
        let(:fixed_rand_value) { 0.1 }

        it { is_expected.to be true }
      end
    end
  end
end
