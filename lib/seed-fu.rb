require 'active_record'

module SeedFu
  autoload :Seeder, 'seed-fu/seeder'
  autoload :ActiveRecordExtension, 'seed-fu/active_record_extension'
end

class ActiveRecord::Base
  extend SeedFu::ActiveRecordExtension
end
