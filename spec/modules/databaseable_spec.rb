require File.dirname(__FILE__) + "/../../lib/modules/databaseable"

describe Databaseable do
	class ChildClass
		extend Databaseable

		def initialize(id:)
			@id = id
		end
	end

	class SecondChildClass
		extend Databaseable

		def initialize(id:)
			@id = id
		end
	end

	context "when it is inherited in a child class" do
		before(:each) do
			ChildClass.destroy_all
		end

		context "when the child class is initialized" do
			let(:instance_id) { 14 }
			let!(:child_class_instance) { ChildClass.new(id: instance_id) }

			it "calling find on the class with the model's id should locate the instance" do
				expect(ChildClass.find(instance_id)).to eq(child_class_instance)
			end

			it "ChildClass.instances should have one element" do
				expect(ChildClass.instances.length).to be 1
			end
		end
	end

	context "when it is inherited by multiple child classes" do
		before :each do
			ChildClass.destroy_all
			SecondChildClass.destroy_all
		end

		context "when ChildClass is initialized" do
			let(:instance_id) { 14 } 
			let!(:child_class_instance) { ChildClass.new(id: instance_id) }

			it "calling find on ChildClass with the model's id should locate the instance" do
				expect(ChildClass.find(instance_id)).to eq(child_class_instance)
			end

			it "ChildClass.instances should have one element" do
				expect(ChildClass.instances.length).to be 1
			end

			it "calling find SecondChildClass with the model's id should return nil" do
				expect(SecondChildClass.find(instance_id)).to be nil
			end

			it "SecondChildClass.instances should have zero elements" do
				expect(SecondChildClass.instances.length).to be 0
			end
		end
	end
end