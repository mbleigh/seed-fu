require 'zlib'

module SeedFu
  class Runner
    def initialize(fixture_path = nil, filter = nil)
      @fixture_path = fixture_path || SeedFu.fixture_path
      @filter       = filter
    end

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
        filenames  = (Dir[File.join(@fixture_path, '*.rb')] +
                      Dir[File.join(@fixture_path, '*.rb.gz')]).sort

        if defined?(Rails)
          filenames += (Dir[File.join(@fixture_path, Rails.env, '*.rb')] +
                        Dir[File.join(@fixture_path, Rails.env, '*.rb.gz')]).sort
        end

        filenames.uniq!
        filenames = filenames.find_all { |filename| filename =~ @filter } if @filter
        filenames
      end
  end
end
