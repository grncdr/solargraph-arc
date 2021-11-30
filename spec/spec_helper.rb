ENV["RAILS_ENV"] = "test"

require 'solargraph'
require 'solar-rails'
require 'pry'
require_relative './helpers'

class Solargraph::Pin::Base
  def inspect
    "#<#{self.class} `#{self.path}`>"
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include(Helpers)
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = "tmp/examples.txt"
  config.disable_monkey_patching!

  config.before(:suite) do
    # NOTE: without this, gem logic does not see gems inside sample project"
    Bundler.reset_rubygems!
  end

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed
end
