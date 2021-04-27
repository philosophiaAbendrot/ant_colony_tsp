require File.dirname(__FILE__) + "/../../lib/modules/databaseable"
require File.dirname(__FILE__) + "/../../lib/modules/identifiable"

describe Databaseable do
	class ChildClass
		extend Databaseable
		include Identifiable
	end

	class SecondChildClass
		extend Databaseable
		include Identifiable
	end

	context "when it is inherited in a child class" do
		before(:each) do
			ChildClass.destroy_all
		end

		context "when the child class is initialized" do
			let!(:child_class_instance) { ChildClass.new }

			it "should update last id" do
				expect(ChildClass.last_id).to be 0
			end

			it "calling find on the class with the model's id should locate the instance" do
				expect(ChildClass.find(0)).to eq(child_class_instance)
			end
		end
	end

	context "when it is inherited by multiple child classes" do
		before :each do
			ChildClass.destroy_all
			SecondChildClass.destroy_all
		end

		context "when ChildClass is initialized" do
			let!(:child_class_instance) { ChildClass.new }

			it "should update last id on ChildClass" do
				expect(ChildClass.last_id).to be 0
			end

			it "SecondChildClass last id should remain -1" do
				expect(SecondChildClass.last_id).to be -1
			end

			it "calling find on ChildClass with the model's id should locate the instance" do
				expect(ChildClass.find(0)).to eq(child_class_instance)
			end

			it "calling find SecondChildClass with the model's id should return nil" do
				expect(SecondChildClass.find(0)).to be nil
			end
		end
	end
end