module SeedFu
  module ActiveRecordExtension
    # Creates a single record of seed data for use
    # with the db:seed rake task.
    #
    # === Parameters
    # constraints :: Immutable reference attributes. Defaults to :id
    def seed(*constraints, &block)
      SeedFu::Seeder.plant(self, *constraints, &block)
    end

    def seed_once(*constraints, &block)
      constraints << true
      SeedFu::Seeder.plant(self, *constraints, &block)
    end

    def seed_many(*constraints)
      seeds = constraints.pop
      seeds.each do |seed_data|
        seed(*constraints) do |s|
          seed_data.each_pair do |k,v|
            s.send "#{k}=", v
          end
        end
      end
    end
  end
end
