module SeedFu
  
  module Writer

    class SeedMany < Abstract

      def add_seed(hash)
        seed_handle.syswrite( (<<-END
#{',' if self.after_first_line}
  { #{hash.collect{|k,v| ":#{k} => '#{v.to_s.gsub("'", "\'")}'"}.join(', ')} }
        END
        ).chomp )
        super(hash)
      end

      def write_header
        super
        seed_handle.syswrite( (<<-END
#{config[:seed_model]}.seed_many(#{config[:seed_by].collect{|s| ":#{s}"}.join(',')},[
        END
        ).chomp )
      end

      def write_footer
        seed_handle.syswrite "\n])\n"
        super
      end

    end

  end

end
