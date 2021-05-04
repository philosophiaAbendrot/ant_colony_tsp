module Ant
	class VertexPreferenceGenerator
		def self.execute(outgoing_edges:, visited_vertex_ids:)
			prospective_edges = outgoing_edges.select { |edge| !visited_vertex_ids.include?(edge.end_vertex_id) }
			sum_products = 0
			preference_mapping = []

			prospective_edges.each do |edge|
				product = (edge.trail_density)**AntColonyTsp::ALPHA_VALUE * (1 / edge.cost_of_traversal)**AntColonyTsp::BETA_VALUE
				sum_products += product
				# store end vertex id and cumulative probability
				preference_mapping << [edge.end_vertex_id, sum_products]
			end

			# normalize the mapping
			normalized_preference_mapping = preference_mapping.map { |el| [el[0], el[1] / sum_products]  }

			normalized_preference_mapping
		end
	end
end