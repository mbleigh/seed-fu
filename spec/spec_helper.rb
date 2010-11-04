require 'rubygems'
require 'bundler/setup'
require 'seed-fu'
require 'logger'

RSpec.configure do |config|
  config.before do
    SeededModel.delete_all
  end
end

SeedFu.quiet = true

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/../debug.log")
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => File.dirname(__FILE__) + "/test.sqlite3"
)

ActiveRecord::Schema.define :version => 0 do
  create_table :seeded_models, :force => true do |t|
    t.column :login, :string
    t.column :first_name, :string
    t.column :last_name, :string
    t.column :title, :string
  end
end

class SeededModel < ActiveRecord::Base
  validates_presence_of :title
  attr_protected :first_name
end
