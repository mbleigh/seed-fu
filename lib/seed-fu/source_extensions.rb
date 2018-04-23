# Depending on what has been predefined, these may need to be required.
require 'date' unless defined?(::DateTime)
require 'time' unless ::Time.respond_to?(:iso8601)

class ::Object
  def seed_fu_source
    inspect
  end
end

module ::SeedFu
  module RecursiveSource
    def seed_fu_source      
      escaped_result = (convert = ->(obj) do
        case obj
        when ::Array
          obj.map {|v| convert.call(v)}
        when ::Hash
          ::Hash[obj.map{|k,v| [convert.call(k), convert.call(v)]}]
        else
          obj.seed_fu_source
        end
      end)[self].inspect

      # We did inspect because the hash must be converted to a string, but
      # now we must convert the double-escaped string to a single escaped
      # string and remove quote wrappers around code and numbers.
      #
      # For a list of the escape codes handled here:
      # http://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals#Backslash_Notation
      result = ''
      parse_mode = :normal
      escape_char_array = nil
      escaped_result.each_char do |c|
        if parse_mode == :special
          chars_left -= 1
          escape_char_array << c
          if chars_left == 0
            if escape_char_array[0] == 'M' && escape_char_array[2] == "\\"
              chars_left = 3
            else
              result << eval(['"\\', *escape_char_array, '"'].join)
              parse_mode = :normal
            end
          end
        elsif parse_mode == :normal_escape
          case c
          when 'n'; result << "\n"
          when 's'; result << "\s"
          when 'r'; result << "\r"
          when 't'; result << "\t"
          when 'v'; result << "\v"
          when 'f'; result << "\f"
          when 'b'; result << "\b"
          when 'a'; result << "\a"
          when 'e'; result << "\e"
          when 'r'; result << "\r"
          when *(0..9); escape_char_array = [c]; parse_mode = :special; chars_left = 2 # we got \n and need nn
          when 'x'; escape_char_array = [c]; parse_mode = :special; chars_left = 2 # we got \x and need nn
          when 'u'; escape_char_array = [c]; parse_mode = :special; chars_left = 4 # we got \u and need nnnn
          when 'c'; escape_char_array = [c]; parse_mode = :special; chars_left = 1 # we got \c and need x
          when 'C'; escape_char_array = [c]; parse_mode = :special; chars_left = 2 # we got \C and need -x
          when 'M'; escape_char_array = [c]; parse_mode = :special; chars_left = 2 # we got \M and need -x, or got \M and need -\C-x
          else
            result << c
            parse_mode = :normal
          end
        else
          case c
          when "\\"; parse_mode = :normal_escape
          when '"' # ignore unescaped quote, since we are unescaping
          else
            result << c
          end
        end
      end

      result
    end
  end
end

class ::Array
  include ::SeedFu::RecursiveSource
end

class ::Hash
  include ::SeedFu::RecursiveSource
end

class ::ActiveSupport::TimeWithZone
  def seed_fu_source
    "DateTime.iso8601(#{iso8601.inspect})"
  end
end if defined?(::ActiveSupport::TimeWithZone) 

class ::DateTime
  def seed_fu_source
    "DateTime.iso8601(#{iso8601.inspect})"
  end
end

class ::Date
  def seed_fu_source
    "Date.iso8601(#{iso8601.inspect})"
  end
end

class ::Time
  def seed_fu_source
    "Time.iso8601(#{iso8601.inspect})"
  end
end
