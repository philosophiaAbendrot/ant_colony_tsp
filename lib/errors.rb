# Public: General error class.
class Error < StandardError
end

# Public: Error due to path not being found by ACO algorithm.
class PathNotFoundError < Error
end