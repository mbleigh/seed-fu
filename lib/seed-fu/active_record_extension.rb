module SeedFu
  module ActiveRecordExtension
    def seed(*args, &block)
      SeedFu::Seeder.new(self, *parse_seed_fu_args(args, block)).seed
    end

    def seed_once(*args, &block)
      constraints, data = parse_seed_fu_args(args, block)
      SeedFu::Seeder.new(self, constraints, data, :insert_only => true).seed
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
