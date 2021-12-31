# frozen_string_literal: true

require 'spec_helper'

describe Graph::Graph do
  context 'when provided with a number of edges and vertices' do
    let(:edge_params) do
      [{ id: 1, start_vertex_id: 3, end_vertex_id: 4, cost_of_traversal: 5 },
       { id: 2, start_vertex_id: 4, end_vertex_id: 3, cost_of_traversal: 3 }]
    end
    let(:vertex_params) { [{ id: 3, x_pos: 4, y_pos: 5 }, { id: 4, x_pos: 5.0, y_pos: 6.0 }] }
    let(:config) { Config.new.process_configs }
    let(:mock_vertex_instance_3) { double('vertex_3', outgoing_edge_ids: []) }
    let(:mock_vertex_instance_4) { double('vertex_4', outgoing_edge_ids: []) }
    let(:mock_edge_instance_1) do
      double('edge_1', id: 1, start_vertex_id: 3, end_vertex_id: 4, start_vertex: mock_vertex_instance_3,
                       end_vertex: mock_vertex_instance_4)
    end
    let(:mock_edge_instance_2) do
      double('edge_2', id: 2, start_vertex_id: 4, end_vertex_id: 3, start_vertex: mock_vertex_instance_4,
                       end_vertex: mock_vertex_instance_3)
    end
    let(:initial_trail_density) { 5 }
    let(:rho) { 0.7 }

    def generate_graph
      config.initial_trail_density = initial_trail_density
      config.rho = rho
      config.process_configs
      Graph::Graph.set_config(config)
      Graph::Edge.set_config(config)

      Graph::Graph.new(edge_inputs: edge_params, vertex_inputs: vertex_params)
    end

    def generate_graph
      config.initial_trail_density = initial_trail_density
      config.rho = rho
      config.process_configs
      Graph::Graph.set_config(config)
      Graph::Edge.set_config(config)

      Graph::Graph.new(edge_inputs: edge_params, vertex_inputs: vertex_params)
    end

    before(:each) do
      Graph::Vertex.destroy_all
      Graph::Edge.destroy_all
      allow(Graph::Edge).to receive(:find).with(1).and_return(mock_edge_instance_1)
      allow(Graph::Edge).to receive(:find).with(2).and_return(mock_edge_instance_2)
      allow(Graph::Edge).to receive(:all).and_return([mock_edge_instance_1, mock_edge_instance_2])
      allow(Graph::Edge).to receive(:initialize_trail_densities)
    end

    describe 'vertices should be initialized' do
      let(:vertex_instance_double) { instance_double(Graph::Vertex) }

      it 'should call Vertex.new for each vertex entry passed' do
        expect(Graph::Vertex).to receive(:new).exactly(vertex_params.length).times
        generate_graph
      end

      describe 'vertices should be initialized with parameters in correct format' do
        let(:vertex_params) { [{ id: 3, x_pos: 4.0, y_pos: 5.0 }] }

        it 'vertex parameter passed should be in correct format' do
          first_vertex = vertex_params[0]

          expect(Graph::Vertex).to receive(:new)
            .with(hash_including(
              id:    first_vertex[:id],
              x_pos: first_vertex[:x_pos],
              y_pos: first_vertex[:y_pos]
            )
          )

          generate_graph
        end
      end
    end

    describe 'edges should be initialized' do
      before(:each) do
        allow(Graph::Vertex).to receive(:new)
      end

      it 'should call Edge.new for each Edge entry passed' do
        expect(Graph::Edge).to receive(:new).exactly(edge_params.length).times
        generate_graph
      end

      describe 'edges should be initialized with parameters in correct format' do
        let(:edge_params) { [{ id: 1, start_vertex_id: 3, end_vertex_id: 4, cost_of_traversal: 5 }] }

        it 'edge parameter passed should be in correct format' do
          first_edge = edge_params[0]
          expect(Graph::Edge).to receive(:new).with(
            hash_including(
              id:                first_edge[:id],
              start_vertex_id:   first_edge[:start_vertex_id],
              end_vertex_id:     first_edge[:end_vertex_id],
              cost_of_traversal: first_edge[:cost_of_traversal]
            )
          )
          generate_graph
        end
      end
    end

    describe 'connecting edges to vertices' do
      let(:edge_params) do
        [{ id: 1, start_vertex_id: 3, end_vertex_id: 4, cost_of_traversal: 5 },
         { id: 2, start_vertex_id: 4, end_vertex_id: 3, cost_of_traversal: 3 }]
      end
      let(:vertex_params) { [{ id: 3, x_pos: 4, y_pos: 5 }, { id: 4, x_pos: 5.0, y_pos: 6.0 }] }
      let(:vertex3) do
        instance_double(Graph::Vertex, id: 3, x_pos: 4, y_pos: 5)
      end
      let(:vertex4) do
        instance_double(Graph::Vertex, id: 4, x_pos: 5.0, y_pos: 6.0)
      end
      let(:edge1) do
        instance_double(
          Graph::Edge, id: 1, start_vertex: vertex3
          end_vertex_id: 4, cost_of_traversal: 5,
        )
      end
      let(:edge2) do
        instance_double(
          Graph::Edge, id: 2, start_vertex: vertex4,
          end_vertex_id: 3, cost_of_traversal: 3
        )
      end

      before(:each) do
        Graph::Vertex.destroy_all
        Graph::Edge.destroy_all
        allow(Graph::Edge).to receive(:all).and_return([edge1, edge2])
      end

      it 'outgoing edge ids should be populated' do
        vertex3 = Graph::Vertex.find(3)
        vertex4 = Graph::Vertex.find(4)

        expect(vertex3.outgoing_edge_ids).to eq([1])
        expect(vertex4.outgoing_edge_ids).to eq([2])

        expect(edge1).to receive_message_chain(
          :start_vertex, :outgoing_edge_ids
        ).with(1)
        expect(edge1).to receive_message_chain(
          :start_vertex, :outgoing_edge_ids
        ).with(2)
        generate_graph
      end
    end
  end
end

