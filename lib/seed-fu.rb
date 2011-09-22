require 'active_record'
require 'active_support/core_ext/module/attribute_accessors'
require File.expand_path('seed-fu/railtie', File.dirname(__FILE__)) if defined?(Rails) && Rails.version >= "3"

module SeedFu
  autoload :VERSION,               File.expand_path('seed-fu/version', File.dirname(__FILE__))
  autoload :Seeder,                File.expand_path('seed-fu/seeder',  File.dirname(__FILE__))
  autoload :ActiveRecordExtension, File.expand_path('seed-fu/active_record_extension', File.dirname(__FILE__))
  autoload :BlockHash,             File.expand_path('seed-fu/block_hash', File.dirname(__FILE__))
  autoload :Runner,                File.expand_path('seed-fu/runner',  File.dirname(__FILE__))
  autoload :Writer,                File.expand_path('seed-fu/writer',  File.dirname(__FILE__))

  mattr_accessor :quiet

  # Set `SeedFu.quiet = true` to silence all output
  @@quiet = false

  mattr_accessor :fixture_paths

  # Set this to be an array of paths to directories containing your seed files. If used as a Rails
  # plugin, SeedFu will set to to contain `Rails.root/db/fixtures` and
  # `Rails.root/db/fixtures/Rails.env`
  @@fixture_paths = ['db/fixtures']

  # Load seed data from files
  # @param [Array] fixture_paths The paths to look for seed files in
  # @param [Regexp] filter If given, only filenames matching this expression will be loaded
  def self.seed(fixture_paths = SeedFu.fixture_paths, filter = nil)
    Runner.new(fixture_paths, filter).run
  end
end

# @public
class ActiveRecord::Base
  extend SeedFu::ActiveRecordExtension
end
