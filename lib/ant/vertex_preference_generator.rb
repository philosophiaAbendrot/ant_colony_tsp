module Ant
	class VertexPreferenceGenerator
		def self.execute(outgoing_edges:, visited:)
			prospective_edges = outgoing_edges.select { |edge| !visited.include?(edge.end_vertex_id) }
			sum_products = 0
			preference_mapping = {}

			prospective_edges.each do |edge|
				product = (edge.trail_density)**AntColonyTsp::ALPHA_VALUE * (1 / edge.cost_of_traversal)**AntColonyTsp::BETA_VALUE
				sum_products += product
				preference_mapping[edge.end_vertex_id] = product
			end

			normalized_preference_mapping = {}

			preference_mapping.each do |k, v|
				normalized_preference_mapping[k] = v / sum_products
			end

			# logic in progress
			preferences = preferences.to_a.sort_by { |el| el[1] }
			cumulative_probability = 0

			preferences.each do |pref|
				cumulative_probability += pref[1]
				cumulative_preferences << [pref[0], cumulative_probability]
			end
		end
	end
end