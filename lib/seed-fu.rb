require 'active_support/core_ext/module/attribute_accessors'
require 'seed-fu/railtie' if defined?(Rails) && Rails.version >= "3"

module SeedFu
  autoload :VERSION,               'seed-fu/version'
  autoload :Seeder,                'seed-fu/seeder'
  autoload :ModelExtension,        'seed-fu/model_extension'
  autoload :BlockHash,             'seed-fu/block_hash'
  autoload :Runner,                'seed-fu/runner'
  autoload :Writer,                'seed-fu/writer'

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
begin
  require 'active_record'
  class ActiveRecord::Base
    extend SeedFu::ModelExtension
  end
rescue LoadError
end

begin
  require 'mongoid'
  module Mongoid::Document
    module ClassMethods
      include SeedFu::ModelExtension
    end
  end
rescue LoadError
end
