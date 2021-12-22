require 'spec_helper'

describe Graph::Vertex do
  describe 'initialize' do
    let(:vertex_params) { { x_pos: 3.5, y_pos: -5.0, id: 1 } }
    let(:vertex) { Graph::Vertex.find(vertex_params[:id]) }

    before(:each) do
      Graph::Vertex.new(vertex_params)
    end

    it 'should initialize a vertex instance' do
      expect(vertex).to_not be nil
    end

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
