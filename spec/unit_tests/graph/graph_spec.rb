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
    let(:vertex3) { instance_double(Graph::Vertex, outgoing_edge_ids: []) }
    let(:vertex4) { instance_double(Graph::Vertex, outgoing_edge_ids: []) }
    let(:edge1) do
      instance_double(Graph::Edge, id: 1, start_vertex_id: 3, end_vertex_id: 4,
                                   start_vertex: vertex3,
                                   end_vertex: vertex4)
    end
    let(:edge2) do
      instance_double(Graph::Edge, id: 2, start_vertex_id: 4, end_vertex_id: 3,
                                   start_vertex: vertex4,
                                   end_vertex: vertex3)
    end
    let(:edge_class) { class_double('Graph::Edge') }
    let(:vertex_class) { class_double('Graph::Vertex') }
    let(:initial_trail_density) { 5 }
    let(:rho) { 0.7 }

    def generate_graph
      config.initial_trail_density = initial_trail_density
      config.rho = rho
      config.process_configs
      Graph::Graph.new(edge_inputs: edge_params, vertex_inputs: vertex_params)
    end

    before do
      allow(edge_class).to receive(:find).with(1).and_return(edge1)
      allow(edge_class).to receive(:find).with(2).and_return(edge2)
      allow(edge_class).to receive(:all).and_return([edge1, edge2])
      allow(edge_class).to receive(:initialize_trail_densities)
      allow(edge_class).to receive(:new)

      stub_const('Graph::Edge', edge_class)
      stub_const('Graph::Vertex', vertex_class)
    end

    describe 'vertices should be initialized' do
      it 'should call Vertex.new for each vertex entry passed' do
        expect(vertex_class).to receive(:new).exactly(vertex_params.length).times
        generate_graph
      end

      describe 'vertices should be initialized with parameters in correct format' do
        let(:vertex_params) { [{ id: 3, x_pos: 4.0, y_pos: 5.0 }] }

        it 'vertex parameter passed should be in correct format' do
          first_vertex = vertex_params[0]

          expect(vertex_class).to receive(:new)
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
      before do
        allow(vertex_class).to receive(:new)
      end

      it 'should call Edge.new for each Edge entry passed' do
        expect(edge_class).to receive(:new).exactly(edge_params.length).times
        generate_graph
      end

      describe 'edges should be initialized with parameters in correct format' do
        let(:edge_params) { [{ id: 1, start_vertex_id: 3, end_vertex_id: 4, cost_of_traversal: 5 }] }

        it 'edge parameter passed should be in correct format' do
          first_edge = edge_params[0]
          expect(edge_class).to receive(:new).with(
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
          Graph::Edge, id: 1, start_vertex: vertex3,
          end_vertex_id: 4, cost_of_traversal: 5,
        )
      end
      let(:edge2) do
        instance_double(
          Graph::Edge, id: 2, start_vertex: vertex4,
          end_vertex_id: 3, cost_of_traversal: 3
        )
      end

      before do
        allow(edge_class).to receive(:all).and_return([edge1, edge2])
        allow(vertex_class).to receive(:new)
      end

      it 'outgoing edge ids should be populated' do
        expect(vertex3).to(
          receive_message_chain(:outgoing_edge_ids, :<<).with(edge1.id)
        )

        expect(vertex4).to(
          receive_message_chain(:outgoing_edge_ids, :<<).with(edge2.id)
        )

        generate_graph
      end
    end
  end
end

