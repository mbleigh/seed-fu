require 'zlib'
require 'active_support/core_ext/array/wrap'

module SeedFu
  # Runs seed files.
  #
  # It is not recommended to use this class directly. Instead, use {SeedFu.seed SeedFu.seed}, which creates
  # an instead of {Runner} and calls {#run #run}.
  #
  # @see SeedFu.seed SeedFu.seed
  class Runner
    # @param [Array<String>] fixture_paths The paths where fixtures are located. Will use
    #   `SeedFu.fixture_paths` if {nil}. If the argument is not an array, it will be wrapped by one.
    # @param [Regexp] filter If given, only seed files with a file name matching this pattern will
    #   be used
    def initialize(fixture_paths = nil, filter = nil)
      @fixture_paths = Array.wrap(fixture_paths || SeedFu.fixture_paths)
      @filter        = filter
    end

    # Run the seed files.
    def run
      puts "\n== Filtering seed files against regexp: #{@filter.inspect}" if @filter && !SeedFu.quiet

      filenames.each do |filename|
        run_file(filename)
      end
    end

    private

      def run_file(filename)
        puts "\n== Seed from #{filename}" unless SeedFu.quiet

        ActiveRecord::Base.transaction do
          open(filename) do |file|
            chunked_ruby = ''
            file.each_line do |line|
              if line == "# BREAK EVAL\n"
                eval(chunked_ruby)
                chunked_ruby = ''
              else
                chunked_ruby << line
              end
            end
            eval(chunked_ruby) unless chunked_ruby == ''
          end
        end
      end

      def open(filename)
        if filename[-3..-1] == '.gz'
          Zlib::GzipReader.open(filename) do |file|
            yield file
          end
        else
          File.open(filename) do |file|
            yield file
          end
        end
      end

      def filenames
        filenames = []
        @fixture_paths.each do |path|
          filenames += (Dir[File.join(path, '*.rb')] + Dir[File.join(path, '*.rb.gz')]).sort
        end
        filenames.uniq!
        filenames = filenames.find_all { |filename| filename =~ @filter } if @filter
        filenames
      end
  end
end
