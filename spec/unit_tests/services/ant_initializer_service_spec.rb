# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AntInitializerService do
  describe '#execute' do
    let(:ant_class) { class_double(Ant::Ant) }
    let(:vertices) do
      vertex1 = double(x_pos: 2.6, y_pos: 8.4, id: 1)
      vertex2 = double(x_pos: -59.5, y_pos: -61, id: 2)

      [vertex1, vertex2]
    end
    let(:num_ants) { 10 }
    let(:ant_instance) do
      instance_double(Ant::Ant, 'current_vertex_id=': nil)
    end

    subject(:result) do
      AntInitializerService.new(
        num_ants,
        vertices
      ).execute
    end

    before do
      stub_const('Ant::Ant', ant_class)
      allow_any_instance_of(described_class).to(
        receive(:rand).and_return(rand_gen_result)
      )
    end

    let(:rand_gen_result) { 1 }

    describe 'instantiates ants' do
      it 'instantiates the correct number of ants' do
        expect(ant_class).to receive(:new).exactly(num_ants).times.and_return(
          ant_instance
        )

        result
      end
    end

    describe 'places ants' do
      it 'places ants in random locations', :aggregate_failures do
        random_current_vertex_id = vertices[rand_gen_result].id

        allow(ant_class).to receive(:new) do |args|
          expect(args[:current_vertex_id]).to eq random_current_vertex_id
        end.and_return(ant_instance)

        result
      end
    end
  end
end
