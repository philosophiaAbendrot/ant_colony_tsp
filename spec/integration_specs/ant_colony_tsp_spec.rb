require "spec_helper"
# require File.expand_path("../support/test_input_generator/base_graph_generator", __dir__)
require_relative "../support/test_input_generator/base_graph_generator"
require_relative "../support/test_input_generator/complete_graph_generator"
require_relative "../support/test_input_generator/incomplete_graph_generator"
require_relative "../support/test_input_generator/test_input_generator"

describe AntColonyTsp, type: :feature do
	let(:include_edges_data) { false }
	let(:include_path_length_vs_iteration) { false }
	let(:initial_trail_density) { AntColonyTsp::INITIAL_TRAIL_DENSITY }
	let(:trail_persistence) { AntColonyTsp::RHO }

	before(:each) do
		allow(ant_class).to receive(:all).and_return(Array.new(AntColonyTsp::DEFAULT_NUM_ANTS) { double("ant_element", id: 5) })
		allow(rand_gen_double).to receive(:rand_int).and_return(vertex_params.length - 1)
	end

	after(:each) do
		Graph::Edge.destroy_all
		Graph::Vertex.destroy_all
	end
	
	def initialize_ant_colony_tsp
		AntColonyTsp.new(edge_inputs: edge_params,
						vertex_inputs: vertex_params,
						graph_class: graph_class,
						vertex_class: vertex_class,
						edge_class: edge_class,
						ant_class: ant_class,
						rand_gen: rand_gen_double,
						include_edges_data: include_edges_data,
						include_path_length_vs_iteration: include_path_length_vs_iteration)
	end

	def read_inputs_from_file
		edges_file_path = File.expand_path("../data/constant_difficulty/test_edge_inputs.json", __dir__)
		vertices_file_path = File.expand_path("../data/constant_difficulty/test_vertex_inputs.json", __dir__)
		edges_file = File.read(edges_file_path)
		vertices_file = File.read(vertices_file_path)
		edge_inputs = JSON.parse(edges_file)
		vertex_inputs = JSON.parse(vertices_file)
	end

	def generate_inputs(num_vertices)
		# generate inputs by using input generator class
		TestInputGenerator.execute(complete_graph: true, num_vertices: num_vertices, write_to_file: false)
	end

	describe "running test with small data set" do
		before(:all) do
			generate_inputs(5)
		end
	end

	def drive_test(edge_inputs, vertex_inputs)
		# convert edges and vertices keys to symbols
		result = execute(edge_inputs: edge_inputs, vertex_inputs: vertex_inputs, include_edges_data: true, include_path_length_vs_iteration: true)

		puts "shortest path edges = #{result[:edges]}"
		puts "shortest path vertices = #{result[:vertices]}"
		puts "shortest path length = #{result[:path_length]}"

		end_time = Time.now

		# printout results
		# Ant::Ant.all.each do |ant|
		# 	puts "#{ant.visited_vertex_ids.length} || #{ant.visited_vertex_ids} || #{ant.find_path_length}"
		# end

		puts "execution time: #{(end_time - start_time) * 1_000} ms"

		# true
		result
	end
end