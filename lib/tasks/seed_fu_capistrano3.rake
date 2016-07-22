namespace :db do
  desc 'Load seed data into database'
  task :seed_fu do |_, args|
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          args = []
          %w(FIXTURE_PATH FILTER).each do |key|
            args << "#{key}=#{ENV[key]}" if ENV.include? key
          end
          execute :bundle, :exec, :rake, 'db:seed_fu', args
        end
      end
    end
  end
end
