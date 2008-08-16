namespace :db do
  desc "Loads seed data from db/fixtures for the current environment."
  task :seed => :environment do
    fixture_path = ENV["FIXTURE_PATH"] ? ENV["FIXTURE_PATH"] : "db/fixtures"
    Dir[File.join(RAILS_ROOT, fixture_path, '*.rb')].sort.each { |fixture| 
      puts "\n== Seeding from #{File.split(fixture).last} " + ("=" * (60 - (17 + File.split(fixture).last.length)))
      load fixture 
      puts "=" * 60 + "\n"
    }
    Dir[File.join(RAILS_ROOT, fixture_path, RAILS_ENV, '*.rb')].sort.each { |fixture| 
      puts "\n== [#{RAILS_ENV}] Seeding from #{File.split(fixture).last} " + ("=" * (60 - (20 + File.split(fixture).last.length + RAILS_ENV.length)))
      load fixture 
      puts "=" * 60 + "\n"
    }
  end
end