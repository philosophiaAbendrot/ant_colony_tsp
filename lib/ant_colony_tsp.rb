class AntColonyTsp
	attr_reader :time

	def initialize(edges:, vertices:)
		@time = 0
		
		# edge input format
		# [id: integer, start_vertex_id: integer, end_vertex_id: integer, cost_of_traversal: double]
	end	
end