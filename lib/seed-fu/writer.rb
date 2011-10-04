module SeedFu
  # {Writer} is used to programmatically generated seed files. For example, you might want to write
  # a script which converts data in a CSV file to a valid Seed Fu seed file, which can then be
  # imported.
  #
  # @example Basic usage
  #   SeedFu::Writer.write('path/to/file.rb', :class_name => 'Person', :constraints => [:first_name, :last_name]) do |writer|
  #     writer.add(:first_name => 'Jon',   :last_name => 'Smith',    :age => 21)
  #     writer.add(:first_name => 'Emily', :last_name => 'McDonald', :age => 24)
  #   end
  #
  #   # Writes the following to the file:
  #   #
  #   # Person.seed(:first_name, :last_name,
  #   #   {:first_name=>"Jon", :last_name=>"Smith", :age=>21},
  #   #   {:first_name=>"Emily", :last_name=>"McDonald", :age=>24}
  #   # )
  class Writer
    cattr_accessor :default_options
    @@default_options = {
      :chunk_size  => 100,
      :constraints => [:id],
      :seed_type   => :seed
    }

    # @param [Hash] options
    # @option options [String] :class_name *Required* The name of the Active Record model to
    #   generate seeds for
    # @option options [Fixnum] :chunk_size (100) The number of seeds to write before generating a
    #   `# BREAK EVAL` line. (Chunking reduces memory usage when loading seeds.)
    # @option options [:seed, :seed_once] :seed_type (:seed) The method to use when generating
    #   seeds. See {ActiveRecordExtension} for details.
    # @option options [Array<Symbol>] :constraints ([:id]) The constraining attributes for the seeds
    def initialize(options = {})
      @options = self.class.default_options.merge(options)
      raise ArgumentError, "missing option :class_name" unless @options[:class_name]
    end

    # Creates a new instance of {Writer} with the `options`, and then calls {#write} with the
    # `io_or_filename` and `block`
    def self.write(io_or_filename, options = {}, &block)
      new(options).write(io_or_filename, &block)
    end

    # Writes the necessary headers and footers, and yields to a block within which the actual
    # seed data should be writting using the `#<<` method.
    #
    # @param [IO] io_or_filename The IO to which writes will be made. (If an `IO` is given, it is
    #   your responsibility to close it after writing.)
    # @param [String] io_or_filename The filename of a file to make writes to. (Will be opened and
    #   closed automatically.)
    # @yield [self] make calls to `#<<` within the block
    def write(io_or_filename, &block)
      raise ArgumentError, "missing block" unless block_given?

      if io_or_filename.respond_to?(:write)
        write_to_io(io_or_filename, &block)
      else
        File.open(io_or_filename, 'w') do |file|
          write_to_io(file, &block)
        end
      end
    end

    # Add a seed. Must be called within a block passed to {#write}.
    # @param [Hash] seed The attributes for the seed
    def <<(seed)
      raise "You must add seeds inside a SeedFu::Writer#write block" unless @io

      buffer = ''

      if chunk_this_seed?
        buffer << seed_footer
        buffer << "# BREAK EVAL\n"
        buffer << seed_header
      end

      buffer << ",\n"
      buffer << '  ' + seed.inspect

      @io.write(buffer)

      @count += 1
    end
    alias_method :add, :<<

    private

      def write_to_io(io)
        @io, @count = io, 0
        @io.write(file_header)
        @io.write(seed_header)
        yield(self)
        @io.write(seed_footer)
        @io.write(file_footer)
      ensure
        @io, @count = nil, nil
      end

      def file_header
        <<-END
# DO NOT MODIFY THIS FILE, it was auto-generated.
#
# Date: #{Time.now}
# Seeding #{@options[:class_name]}
# Written with the command:
#
#   #{$0} #{$*.join}
#
        END
      end

      def file_footer
        <<-END
# End auto-generated file.
        END
      end

      def seed_header
        constraints = @options[:constraints] && @options[:constraints].map(&:inspect).join(', ')
        "#{@options[:class_name]}.#{@options[:seed_type]}(#{constraints}"
      end

      def seed_footer
        "\n)\n"
      end

      def chunk_this_seed?
        @count != 0 && (@count % @options[:chunk_size]) == 0
      end
  end
end
