module SeedFu
  
  module Writer

    class Seed < Abstract

      # This method uses the :seed_by set earlier.
      #
      def add_seed(hash, seed_by=nil)
        seed_by ||= config[:seed_by]
        seed_handle.syswrite( <<-END
#{config[:seed_model]}.seed(#{seed_by.collect{|s| ":#{s}"}.join(',')}) { |s|
#{hash.collect{|k,v| "  s.#{k} = '#{v.to_s.gsub("'", "\'")}'\n"}.join}}
        END
        )
        super(hash)
      end

    end

  end

end
