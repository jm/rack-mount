module Rack
  module Mount
    class SegmentRegexp < Regexp
      def initialize(regexp, requirements = {})
        @requirements = requirements || {}
        super(regexp)
      end

      def segments_keys
        []
      end

      def recognizer
        self
      end

      def params
        @params ||= begin
          @requirements.sort { |a,b|
            a[1].to_i <=> b[1].to_i
          }.transpose[0]
        end
      end

      def freeze
        params

        super
      end
    end
  end
end
