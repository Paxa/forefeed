# Load the testing libraries
require File.expand_path(File.dirname(__FILE__) + '/../forefeed')
require 'spec'
require 'spec/interop/test'
require "rack/test"

# Include the Rack test methods to Test::Unit
Test::Unit::TestCase.send :include, Rack::Test::Methods

# Set the Sinatra environment
set :environment, :test

# Add an app method for RSpec
def app
  Sinatra::Application
end