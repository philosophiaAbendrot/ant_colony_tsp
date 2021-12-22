# Internal: Module which contains models relating to the graph which is the
#   composition of the edges and the vertices which are supplied as an input.
module Graph
  # Internal: Class which represents vertices on the graph.
  class Vertex
    # Logic which stores instances and allow them to be searched.
    extend Databaseable

    # Internal: An Array of type Integer which lists the ids of edges that
    #   are outgoing from this vertex.
    attr_accessor :outgoing_edge_ids

    # Internal: Gets/sets the Float x position of the vertex.
    attr_reader :x_pos

    # Internal: Gets/sets the Float y position of the vertex.
    attr_reader :y_pos

    # Internal: Gets/sets the Integer id of the vertex.
    attr_reader :id

    # Internal: Initializes a vertex.
    #
    # x_pos - The Float x position of the vertex.
    # y_pos - The Float y position of the vertex.
    # id - The Integer id of the vertex.
    #
    # Returns nothing.
    def initialize(x_pos:, y_pos:, id:)
      @id = id
      @x_pos = x_pos.to_f
      @y_pos = y_pos.to_f
      @outgoing_edge_ids = []

      nil
    end
  end
end
