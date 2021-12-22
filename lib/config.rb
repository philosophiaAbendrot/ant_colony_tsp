# Internal: Class used for configuring parameters for various classes.
class Config
  # Internal: Gets/sets the Integer number of ants used for ACO algorithm.
  #   Higher numbers tend to reduce the path length found, but make the
  #   algorithm run longer.
  attr_accessor :num_ants

  # Internal: Gets/sets the Integer number of cycles which the ACO algorithm
  #   runs for. Higher values tend to reduce the path length found, but make
  #   the algorithm run longer.
  attr_accessor :num_iterations

  # Internal: Gets/sets Float coefficient which controls how quickly
  #   pheromone trails evaporate.
  attr_accessor :rho

  # Internal: Gets/sets Float coefficient controlling the importance of
  #   pheromone strength in influencing choice of next vertex.
  attr_accessor :alpha

  # Internal: Gets/sets Float coefficient controlling the importance of
  #   proximity in influencing choice of next vertex.
  attr_accessor :beta

  # Internal: Gets/sets Float coefficient which is the initial trail density
  #   on all edges.
  attr_accessor :initial_trail_density

  # Internal: Gets/sets Float coefficient which controls the amount of trail
  #   density which is deposited by the ant which finds the shortest trail.
  attr_accessor :q

  # Internal: Gets/sets the class used to represent vertices.
  attr_accessor :vertex_class

  # Internal: Gets/sets the class used to represent edges.
  attr_accessor :edge_class

  # Internal: Gets/sets the class used to represent ants.
  attr_accessor :ant_class

  # Internal: Gets/sets the class used to generate random numbers.
  attr_accessor :rand_gen

  # Internal: Gets/sets the class used to represent a graph.
  attr_accessor :graph_class

  # Internal: Initialize Config object.
  def initialize
    @num_ants = 30
    @num_iterations = 50
    @rho = 0.8
    @alpha = 1
    @beta = 1
    @initial_trail_density = 0.05
    @q = 100
    @edge_class = Graph::Edge
    @vertex_class = Graph::Vertex
    @graph_class = Graph::Graph
    @ant_class = Ant::Ant
    @rand_gen = RandGen
  end

  # Internal: Fixes types of certain attributes of Config object.
  #
  # Returns the modified Config object.
  def process_configs
    @rho = @rho.to_f
    @alpha = @alpha.to_f
    @beta = @beta.to_f
    @initial_trail_density = @initial_trail_density.to_f
    @q = @q.to_f
    self
  end
end
