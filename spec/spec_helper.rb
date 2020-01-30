require 'rack/test'
require 'redis'

Dir["#{__dir__}/support/**/*.rb"].each {|f| require f }

ENV["REDIS_URL"] ||= "redis://127.0.0.1:6379/0"

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Rack::Test::Methods
  config.include FixtureUtil

  config.before do
    redis = Redis.new(url: ENV["REDIS_URL"])
    cache_keys = redis.keys(Cache::KEY_PREFIX + "*")

    redis.del(cache_keys) unless cache_keys.empty?
  end

  config.include Rack::Test::Methods
  ENV['SINATRA_ENV'] = 'test'
  ENV['RACK_ENV'] = 'test'

  require_relative "../app"
  def app
    App
  end
end

def spec_dir
  Pathname(__dir__)
end