Gem::Specification.new do |s|
	s.name = "ant_colony_tsp"
	s.version = "0.0.0".freeze
	s.licenses = ["MIT"]
	s.summary = "Uses a colony of virtual ants to solve the travelling salesman problem"
	s.email = "tonytaesung.ha@gmail.com"
	s.authors = ["Tony Ha"]
	s.files = Dir["{lib}/**/*"]
	s.add_dependency("rspec", "3.10.0")
	s.add_dependency("rspec-core", "3.10.1")
	s.add_dependency("rspec-expectations", "3.10.1")
	s.add_dependency("rspec-mocks", "3.10.2")
	s.add_dependency("rspec-support", "3.10.2")
end