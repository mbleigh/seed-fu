require 'rubygems'
require 'bundler/setup'
require 'seed-fu'
require 'logger'

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
  end

  create_table :seeded_model_no_primary_keys, :id => false, :force => true do |t|
    t.column :id, :string
  end

  create_table :seeded_model_no_sequences, :id => false, :force => true do |t|
    t.column :id, :string
  end

  execute("ALTER TABLE seeded_model_no_sequences ADD PRIMARY KEY (id)") if ENV['DB'] == 'postgresql'
end

class SeededModel < ActiveRecord::Base
  validates_presence_of :title
  attr_protected :first_name if self.respond_to?(:protected_attributes)
  attr_accessor :fail_to_save

  before_save { false if fail_to_save }
end

class SeededModelNoPrimaryKey < ActiveRecord::Base

end

class SeededModelNoSequence < ActiveRecord::Base

end

RSpec.configure do |config|
  config.before do
    SeededModel.delete_all
  end
end
