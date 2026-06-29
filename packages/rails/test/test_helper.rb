ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel when there are enough of them.
  parallelize(workers: :number_of_processors) if ENV["PARALLEL"]
end
