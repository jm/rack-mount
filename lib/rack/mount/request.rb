module Rack
  module Mount
    class Request
      def initialize(env)
        @env = env
      end

      def method
        @method ||= @env["REQUEST_METHOD"]
      end

      def path
        @path ||= @env["PATH_INFO"]
      end

      def first_segment
        @first_segment ||= path.slice(SegmentString::FIRST_SEGMENT_REGEXP)
      end
    end
  end
end
