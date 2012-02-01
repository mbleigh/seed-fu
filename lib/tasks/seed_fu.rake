require 'seed-fu'

namespace :db do
  desc <<-EOS
    Loads seed data for the current environment. It will look for
    ruby seed files in <RAILS_ROOT>/db/fixtures/ and
    <RAILS_ROOT>/db/fixtures/<RAILS_ENV>/.

    By default it will load any ruby files found. You can filter the files
    loaded by passing in the FILTER environment variable with a comma-delimited
    list of patterns to include. Any files not matching the pattern will
    not be loaded.

    You can also change the directory where seed files are looked for
    with the FIXTURE_PATH environment variable.

    Examples:
      # default, to load all seed files for the current environment
      rake db:seed_fu:seed

      # to load seed files matching orders or customers
      rake db:seed_fu:seed FILTER=orders,customers

      # to load files from RAILS_ROOT/features/fixtures
      rake db:seed_fu:seed FIXTURE_PATH=features/fixtures
      
      # to write seed files from RAILS_ROOT/lib/db/generators
      rake db:seed_fu:write GENERATOR_PATH=lib/db/generators
      
      # to write seed files from RAILS_ROOT/db/generators
      rake db:seed_fu:write
      
      For more information on writers see http://rubydoc.info/github/mbleigh/seed-fu/master/SeedFu/Writer
      Note: As of 02/01/2012 the documentation for writers is incorrect.  writer.write should be writer.add
      See https://github.com/mbleigh/seed-fu/issues/32
  EOS
  
  
  namespace :seed_fu do
    
    task :seed => :environment do
      if ENV["FILTER"]
        filter = /#{ENV["FILTER"].gsub(/,/, "|")}/
      end

      if ENV["FIXTURE_PATH"]
        fixture_paths = [ENV["FIXTURE_PATH"], ENV["FIXTURE_PATH"] + '/' + Rails.env]
      end

      SeedFu.seed(fixture_paths, filter)
    end
    
    
    task :write => :environment do
      desc <<-EOS
        Generates seeds from the database based on the generators in /db/generators
      EOS
      
      generator_path = ENV["GENERATOR_PATH"] || "#{Rails.root}/db/generators"

      Dir.foreach(generator_path) do |item|
        next if item == "." or item == ".."
        
        puts "Importing #{generator_path}/#{item}"
        require File.absolute_path("#{generator_path}/#{item}")
      end
    end
    
  end
end
