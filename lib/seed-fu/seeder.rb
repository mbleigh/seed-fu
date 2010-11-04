require 'active_support/core_ext/hash/keys'

module SeedFu
  class Seeder
    def initialize(model_class, constraints, data, options = {})
      @model_class = model_class
      @constraints = constraints.to_a.empty? ? [:id] : constraints
      @data        = data.to_a || []
      @options     = options.symbolize_keys

      @options[:quiet] ||= SeedFu.quiet

      validate_constraints!
      validate_data!
    end

    def seed
      @model_class.transaction do
        @data.map { |record_data| seed_record(record_data.symbolize_keys) }
      end
    end

    private

      def validate_constraints!
        unknown_columns = @constraints.map(&:to_s) - @model_class.column_names
        unless unknown_columns.empty?
          raise(ArgumentError,
            "Your seed constraints contained unknown columns: #{column_list(unknown_columns)}. " +
            "Valid columns are: #{column_list(@model_class.column_names)}.")
        end
      end

      def validate_data!
        raise ArgumentError, "Seed data missing" if @data.empty?
      end

      def column_list(columns)
        '`' + columns.join("`, `") + '`'
      end

      def seed_record(data)
        record = find_or_initialize_record(data)
        return if @options[:insert_only] && !record.new_record?
        record.send(:attributes=, data, false)
        puts " - #{@model_class} #{data.inspect}" unless @options[:quiet]
        record.save(:validate => false)
      end

      def find_or_initialize_record(data)
        @model_class.where(constraint_conditions(data)).first ||
        @model_class.new
      end

      def constraint_conditions(data)
        Hash[@constraints.map { |c| [c, data[c.to_sym]] }]
      end
  end
end
