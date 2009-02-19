module Rack
  module Mount
    class SegmentString < String
      SEPARATORS   = %w( / . ? )
      PARAM_REGEXP = /^:(\w+)$/
      GLOB_REGEXP  = /^\\\*(\w+)$/

      def self.first_segment(path)
        path.sub(/^\//, "").split("/")[0]
      end

      def initialize(str, requirements = {})
        raise ArgumentError unless str.is_a?(String)
        str = str.dup
        prepand_slash!(str)
        @requirements = requirements || {}
        super(str)
      end

      def dynamic_first_segment?
        segments[0] =~ PARAM_REGEXP ? true : false
      end

      def segments
        @segments ||= split("/").map! { |segment|
          next if segment == ""
          Regexp.escape(segment)
        }.compact
      end

      def recognizer
        @recognizer ||= begin
          re = segments.map { |segment|
            if segment =~ PARAM_REGEXP
              "#{@requirements[$1.to_sym] || "[^#{SEPARATORS.join}]+"}"
            elsif segment =~ GLOB_REGEXP
              ".*"
            else
              segment
            end
          }.compact.join("\/")
          Regexp.compile("^/#{re}$")
        end
      end

      def local_recognizer
        @local_recognizer ||= begin
          re = segments.map { |segment|
            if segment =~ PARAM_REGEXP
              "(#{@requirements[$1.to_sym] || "[^#{SEPARATORS.join}]+"})"
            elsif segment =~ GLOB_REGEXP
              "(.*)"
            else
              segment
            end
          }.compact.join("\/")
          Regexp.compile("#{re}")
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
        local_recognizer
        params

        super
      end

      private
        def prepand_slash!(str)
          str.replace("/#{str}") if str =~ /^\//
        end
    end
  end
end
