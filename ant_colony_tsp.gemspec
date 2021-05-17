Gem::Specification.new do |s|
	s.name = "ant_colony_tsp"
	s.version = "0.0.0".freeze
	s.licenses = ["MIT"]
	s.summary = "Uses a colony of virtual ants to solve the travelling salesman problem"
	s.email = "tonytaesung.ha@gmail.com"
	s.authors = ["Tony Ha"]
	s.files = Dir["{lib}/**/*"]

	s.required_ruby_version = '~> 2.1.0'
	s.add_dependency("rspec", "~> 3.0.0")
	s.add_dependency("rspec-core", "~> 3.0.0")
	s.add_dependency("rspec-expectations", "~> 3.0.0")
	s.add_dependency("rspec-mocks", "~> 3.0.0")
	s.add_dependency("rspec-support", "~> 3.0.0")
end