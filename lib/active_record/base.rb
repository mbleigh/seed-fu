module ActiveRecord
  class Base
    # Creates a single record of seed data for use
    # with the db:seed rake task. 
    # 
    # === Parameters
    # constraints :: Immutable reference attributes. Defaults to :id
    def self.seed(*constraints, &block)
      SeedFu::Seeder.plant(self, *constraints, &block)
    end
  end
end