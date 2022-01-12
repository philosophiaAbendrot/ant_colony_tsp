# frozen_string_literal: true

require 'spec_helper'

describe Databaseable do
  class ChildClass
    extend Databaseable

    def initialize(id)
      @id = id
    end
  end

  class SecondChildClass
    extend Databaseable

    def initialize(id)
      @id = id
    end
  end

  context 'when it is inherited in a child class' do
    before { ChildClass.destroy_all }

    context 'when the child class is initialized' do
      let(:instance_id) { 14 }
      let!(:child_class_instance) { ChildClass.new(instance_id) }

      it 'calling find on the class with the model\'s id should locate'\
         'the instance' do
        expect(ChildClass.find(instance_id)).to eq(child_class_instance)
      end

      it 'ChildClass.all should have one element' do
        expect(ChildClass.all.length).to eq 1
      end

      it 'ChildClass.all should include the child class instance' do
        expect(ChildClass.all.first).to eq(child_class_instance)
      end

      it 'ChildClass.id_mapping should map the id of the child class to the child class instance' do
        expect(ChildClass.id_mapping[child_class_instance.id]).to eq(child_class_instance)
      end

      it 'ChildClass.id_mapping should have size 1' do
        expect(ChildClass.id_mapping.length).to eq 1
      end
    end
  end

  context 'when it is inherited by multiple child classes' do
    before do
      ChildClass.destroy_all
      SecondChildClass.destroy_all
    end

    context 'when ChildClass is initialized' do
      let(:instance_id) { 14 }
      let!(:child_class_instance) { ChildClass.new(instance_id) }

      it 'calling find on ChildClass with the model\'s id should locate'\
         'the instance' do
        expect(ChildClass.find(instance_id)).to eq(child_class_instance)
      end

      it 'ChildClass.all should have one element' do
        expect(ChildClass.all.length).to be 1
      end

      it 'calling find SecondChildClass with the model\'s id should'\
         'return nil' do
        expect(SecondChildClass.find(instance_id)).to be nil
      end

      it 'SecondChildClass.instances should have zero elements' do
        expect(SecondChildClass.all.length).to be 0
      end

      it 'SecondChildClass.id_mapping should have zero elements' do
        expect(SecondChildClass.id_mapping.empty?).to be true
      end
    end
  end
end
