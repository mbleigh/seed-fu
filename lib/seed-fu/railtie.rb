module SeedFu
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/seed_fu.rake"
    end

    initializer 'seed_fu.set_fixture_paths' do
      SeedFu.fixture_paths = [
        Rails.root.join('db/fixtures').to_s,
        Rails.root.join('db/fixtures/' + Rails.env).to_s
      ]
    end
  end
end
