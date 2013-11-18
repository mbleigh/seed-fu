Capistrano::Configuration.instance.load do
  namespace :db do
    desc "Load seed data into database"
    task :seed_fu, :roles => :db, :only => { :primary => true } do
      run "cd #{release_path} && bundle exec rake RAILS_ENV=#{rails_env} db:seed_fu"
    end
  end
end
