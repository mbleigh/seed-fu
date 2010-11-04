require 'active_record'

module SeedFu
  autoload :Seeder,                'seed-fu/seeder'
  autoload :ActiveRecordExtension, 'seed-fu/active_record_extension'
  autoload :BlockHash,             'seed-fu/block_hash'
  autoload :VERSION,               'seed-fu/version'
  autoload :Runner,                'seed-fu/runner'

  # Turn off the output when seeding data
  mattr_accessor :quiet
  @@quiet = false

  # The location of fixtures
  mattr_accessor :fixture_path
  @@fixture_path = 'db/fixtures'

  def self.seed(fixture_path = nil, filter = nil)
    Runner.new(fixture_path, filter).run
  end
end

class ActiveRecord::Base
  extend SeedFu::ActiveRecordExtension
end
