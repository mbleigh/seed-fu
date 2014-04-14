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
      rake db:seed_fu

      # to load seed files matching orders or customers
      rake db:seed_fu FILTER=orders,customers

      # to load files from RAILS_ROOT/features/fixtures
      rake db:seed_fu FIXTURE_PATH=features/fixtures
  EOS
  task :seed_fu => :environment do
    if ENV["FILTER"]
      filter = /#{ENV["FILTER"].gsub(/,/, "|")}/
    end

    if ENV["FIXTURE_PATH"]
      fixture_paths = [ENV["FIXTURE_PATH"], ENV["FIXTURE_PATH"] + '/' + Rails.env]
    end

    SeedFu.seed(fixture_paths, filter)
  end
end
