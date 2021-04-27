module Databaseable
	module Identifiable
		attr_accessor :id
	end

	def self.extended(klass)
		klass.include(Databaseable::Identifiable)
	end

	def find(id)
		@instances[id]
	end

	def instances
		@instances ||= {}
	end

	def new(*arguments, &block)
		instance = allocate
		instance.send(:initialize, *arguments, &block)
		@instances[instance.id] = instance
		instance
	end

	def destroy_all
		# remove all instances from record
		@instances = {}
	end
end