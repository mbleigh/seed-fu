module SeedFu
  module ActiveRecordExtension
    # Load some seed data. There are two ways to do this.
    #
    # Verbose syntax
    # --------------
    #
    # This will seed a single record. The `:id` parameter ensures that if a record already exists
    # in the database with the same id, then it will be updated with the name and age, rather
    # than created from scratch.
    #
    #     Person.seed(:id) do |s|
    #       s.id   = 1
    #       s.name = "Jon"
    #       s.age  = 21
    #     end
    #
    # Note that `:id` is the default attribute used to identify a seed, so it need not be
    # specified.
    #
    # Terse syntax
    # ------------
    #
    # This is a more succinct way to load multiple records. Note that both `:x` and `:y` are being
    # used to identify a seed here.
    #
    #     Point.seed(:x, :y,
    #       { :x => 3, :y => 10, :name => "Home" },
    #       { :x => 5, :y => 9,  :name => "Office" }
    #     )
    def seed(*args, &block)
      SeedFu::Seeder.new(self, *parse_seed_fu_args(args, block)).seed
    end

    # Has the same syntax as {#seed}, but if a record already exists with the same values for
    # constraining attributes, it will not be updated.
    #
    # @example
    #   Person.seed(:id, :id => 1, :name => "Jon") # => Record created
    #   Person.seed(:id, :id => 1, :name => "Bob") # => Name changed
    #   Person.seed(:id, :id => 1, :name => "Harry") # => Name *not* changed
    def seed_once(*args, &block)
      constraints, data = parse_seed_fu_args(args, block)
      SeedFu::Seeder.new(self, constraints, data, :insert_only => true).seed
    end

    # Shortcut to using SeedFu::Writer on an ActiveRecord::Collection. Useful if
    # you want to dump all of the instances of a model to a seed file. By default
    # it uses all of the attributes of a model, but you can also specify which
    # attributes to use as an option  `attributes: ['id', 'name']`.
    #
    # Check out the SeedFu::Writer documentation for more options.
    #
    # @example
    #   Person.write_seed('path/to/file.rb')
    def write_seed(io_or_filename, options = {})
      options[:class_name] ||= self.name
      options[:attributes] ||= self.column_names
      SeedFu::Writer.write(io_or_filename, options) do |writer|
        all.each do |record|
          attributes = record.attributes.select { |k,_| options[:attributes].include?(k) }
          writer.add(attributes)
        end
      end
    end

    private

      def parse_seed_fu_args(args, block)
        if block.nil?
          if args.last.is_a?(Array)
            # Last arg is an array of data, so assume the rest of the args are constraints
            data = args.pop
            [args, data]
          else
            # Partition the args, assuming the first hash is the start of the data
            args.partition { |arg| !arg.is_a?(Hash) }
          end
        else
          # We have a block, so assume the args are all constraints
          [args, [SeedFu::BlockHash.new(block).to_hash]]
        end
      end
  end
end
