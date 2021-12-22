# Internal: A service class which is used to generate random numbers.
class RandGen
  # Internal: Returns a random Integer object.
  #
  # upper_bound - A Float which is the upper bound of the random number
  #   to be generated.
  #
  # Returns an Integer object with a value between 0 (inclusive) and
  #   upper_bound (exclusive).
  def self.rand_int(upper_bound)
    rand(upper_bound)
  end

  # Internal: Returns a random Float object.
  #
  # Returns a Float object with a value between 0 and 1.
  def self.rand_float
    rand
  end
end
