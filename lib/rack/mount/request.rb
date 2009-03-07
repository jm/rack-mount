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
        split_segments! unless @first_segment
        @first_segment
      end

      def second_segment
        split_segments! unless @second_segment
        @second_segment
      end

      private
        def split_segments!
          _, @first_segment, @second_segment = path.split("/")
        end
    end
  end
end
