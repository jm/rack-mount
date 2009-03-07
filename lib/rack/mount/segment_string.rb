module Rack
  module Mount
    class SegmentString < String
      SEPARATORS   = %w( / . ? )
      PARAM_REGEXP = /^:(\w+)$/
      GLOB_REGEXP  = /^\\\*(\w+)$/
      SEGMENT_REGEXP = /[^\/\.\?]+|[\/\.\?]/

      def initialize(str, requirements = {})
        raise ArgumentError unless str.is_a?(String)
        str = str.dup
        prepand_slash!(str)
        @requirements = requirements || {}
        super(str)
      end

      def segments_keys
        segments.join.split("/").map { |segment|
          if segment == "" || segment =~ PARAM_REGEXP || segment =~ GLOB_REGEXP
            nil
          else
            segment
          end
        }
      end

      def segments
        @segments ||= scan(SEGMENT_REGEXP).map! { |segment|
          next if segment == ""
          Regexp.escape(segment)
        }.compact
      end

      def recognizer
        @recognizer ||= begin
          re = segments.map { |segment|
            if segment =~ PARAM_REGEXP
              "(#{@requirements[$1.to_sym] || "[^#{SEPARATORS.join}]+"})"
            elsif segment =~ GLOB_REGEXP
              "(.*)"
            else
              segment
            end
          }.compact.join
          Regexp.compile("^#{re}$")
        end
      end

      def params
        @params ||= begin
          segments.map { |segment|
            if segment =~ PARAM_REGEXP
              $1.to_sym
            elsif segment =~ GLOB_REGEXP
              $1.to_sym
            end
          }.compact
        end
      end

      def freeze
        segments
        recognizer
        params

        super
      end

      private
        def prepand_slash!(str)
          str.replace("/#{str}") unless str =~ /^\//
        end
    end
  end
end
