# frozen_string_literal: true

require 'spec_helper'

describe Graph::Vertex do
  describe '#initialize' do
    let(:vertex_params) { { x_pos: 3.5, y_pos: -5.0, id: 1 } }

    subject(:vertex) { Graph::Vertex.new(vertex_params) }

    it { is_expected.not_to be nil }

    it 'should correctly set x_pos' do
      expect(vertex.x_pos).to eq(vertex_params[:x_pos])
    end

    it 'should correctly set y_pos' do
      expect(vertex.y_pos).to eq(vertex_params[:y_pos])
    end

    it 'should initialize outgoing edge ids to an empty array' do
      expect(vertex.outgoing_edge_ids).to eq([])
    end
  end
end
