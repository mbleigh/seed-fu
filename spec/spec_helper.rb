require 'rubygems'
require 'bundler/setup'
require 'seed-fu'
require 'logger'
require 'protected_attributes'

SeedFu.quiet = true

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/../debug.log")

ENV["DB"] ||= 'sqlite3'
puts "Using #{ENV["DB"]} to run the tests."
require File.dirname(__FILE__) + "/connections/#{ENV["DB"]}.rb"

ActiveRecord::Schema.define :version => 0 do
  create_table :seeded_models, :force => true do |t|
    t.column :login, :string
    t.column :first_name, :string
    t.column :last_name, :string
    t.column :title, :string
    t.column :is_deleted, :boolean, default: false
  end
end

class SeededModel < ActiveRecord::Base
  validates_presence_of :title
  attr_protected :first_name
  attr_accessor :fail_to_save
  default_scope { where(:is_deleted => false) }

  before_save { false if fail_to_save }
end

RSpec.configure do |config|
  config.before do
    SeededModel.delete_all
  end
end
