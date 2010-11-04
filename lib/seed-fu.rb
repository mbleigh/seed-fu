require 'active_record'

module SeedFu
  autoload :Seeder,                'seed-fu/seeder'
  autoload :ActiveRecordExtension, 'seed-fu/active_record_extension'
  autoload :BlockHash,             'seed-fu/block_hash'
  autoload :VERSION,               'seed-fu/version'

  # Turn off the output when seeding data
  mattr_accessor :quiet
  @@quiet = false
end

class ActiveRecord::Base
  extend SeedFu::ActiveRecordExtension
end
