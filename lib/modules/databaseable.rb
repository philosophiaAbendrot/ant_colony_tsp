# Internal: Module which allows the class that it is extended into to have all
#   its instances to be stored in a class instance field and have them
#   accessible by their id.
module Databaseable
  # Internal: Module which the class that it is extended into to have all
  #   its instances have 'id' as an attribute.
  module Identifiable
    attr_accessor :id
  end

  # Internal: When this module is extended, the Identifiable module is
  #   included into the extending class.
  def self.extended(klass)
    klass.include(Databaseable::Identifiable)
  end

  # Internal: Returns the instance with the given id.
  #
  # id - The Integer id of the object.
  #
  # Returns the object with that id.
  def find(id)
    @instances[id]
  end

  # Internal: Returns a Hash containing the objects of the class that
  #   this module is extended into.
  #
  # Returns the Hash object in which the objects of the class that this
  #   module is extended into are the values and the ids of those objects
  #   are the keys.
  def id_mapping
    @instances || {}
  end

  # Internal: Returns an Array containing all instances of the class that
  #   this module is extended into.
  #
  # Returns the instances of the class that this module is extended into as
  #   an array.
  def all
    @instances ? @instances.values : []
  end

  # Internal: Initializes the class that this module is extended into.
  #   Stores the object within '@instances' hash with the id of the
  #   object as its key.
  #
  #   *arguments - Any arguments which are passed to the class initializer.
  #   &block - Any blocks which are passed to the class initializer.
  #
  # Returns the initialized object.
  def new(*arguments, &block)
    instance = allocate
    instance.send(:initialize, *arguments, &block)

    @instances ||= {}

    @instances[instance.id] = instance

    instance
  end

  # Internal: Destroys all instances of the class that this module is
  #   extended into.
  #
  # Returns nothing.
  def destroy_all
    @instances = {}

    nil
  end
end
