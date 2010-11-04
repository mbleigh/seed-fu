require 'active_record'
require 'seed-fu/railtie' if defined?(Rails) && Rails.version >= "3"

module SeedFu
  autoload :VERSION,               'seed-fu/version'
  autoload :Seeder,                'seed-fu/seeder'
  autoload :ActiveRecordExtension, 'seed-fu/active_record_extension'
  autoload :BlockHash,             'seed-fu/block_hash'
  autoload :Runner,                'seed-fu/runner'
  autoload :Writer,                'seed-fu/writer'

  # Turn off the output when seeding data
  mattr_accessor :quiet
  @@quiet = false

  # The locations of fixtures
  mattr_accessor :fixture_paths
  @@fixture_paths = ['db/fixtures']

  def self.seed(fixture_paths = nil, filter = nil)
    Runner.new(fixture_paths, filter).run
  end
end

class ActiveRecord::Base
  extend SeedFu::ActiveRecordExtension
end
