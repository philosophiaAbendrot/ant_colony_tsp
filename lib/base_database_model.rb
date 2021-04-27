# class to be inherited
# allows class to be instantiated and stores instances of the class in-memory
class BaseDatabaseModel
	@@model_ids = {}
	@@last_id = -1

	attr_accessor :id

	def self.find(id)
		@@model_ids[self.class.name][id]
	end

	def initialize
		if @@model_ids[self.class.name]
			@@model_ids[self.class.name] << self
		else
			@@model_ids[self.class.name] = [self]
		end
	end
end