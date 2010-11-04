module SeedFu
  class Writer
    cattr_accessor :default_options
    @@default_options = {
      :chunk_size  => 100,
      :constraints => [:id],
      :seed_type   => :seed
    }

    def initialize(options = {})
      @options = self.class.default_options.merge(options)
      raise ArgumentError, "missing option :class_name" unless @options[:class_name]
    end

    def self.write(io_or_filename, options = {}, &block)
      new(options).write(io_or_filename, &block)
    end

    def write(io_or_filename, &block)
      if io_or_filename.respond_to?(:write)
        write_to_io(io_or_filename, &block)
      else
        File.open(io_or_filename, 'w') do |file|
          write_to_io(file, &block)
        end
      end
    end

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
