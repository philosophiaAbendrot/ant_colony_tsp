module Databaseable
	def find(id)
		@instances[id]
	end

	def instances
		@instances ||= {}
	end

	def last_id
		@last_id ||= -1
	end

	def new(*arguments, &block)
		instance = allocate

		instance.id = @last_id + 1

		@last_id = instance.id

		@instances[instance.id] = instance
		instance.send(:initialize, *arguments, &block)
		instance
	end

	def destroy_all
		# remove all instances from record
		@instances = {}
		@last_id = -1
	end
end