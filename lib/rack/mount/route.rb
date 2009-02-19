module Rack
  module Mount
    class Route
      SKIP_RESPONSE = [404, {"Content-Type" => "text/html"}, "Not Found"]

      def initialize(options)
        @app = options.delete(:app)
        raise ArgumentError unless @app && @app.respond_to?(:call)

        method = options.delete(:method)
        @method = method.to_s.upcase if method

        @path = options.delete(:path)

        str = SegmentString.new(@path, options.delete(:requirements))

        # Mark as dynamic only if the first segment is dynamic
        @dynamic = str.dynamic_first_segment?

        @recognizer = str.recognizer
        @local_recognizer = str.local_recognizer
        @params = str.params
      end

      def dynamic?
        @dynamic
      end

      def key
        SegmentString.first_segment(@path)
      end

      def call(env)
        method = env["REQUEST_METHOD"]
        path = env["PATH_INFO"]

        if (@method.nil? || method == @method) && path =~ @recognizer
          param_matches = path.scan(@local_recognizer).flatten
          routing_args = {}
          @params.each_with_index { |p,i| routing_args[p] = param_matches[i] }

          env["rack.routing_args"] = routing_args
          @app.call(env)
        else
          SKIP_RESPONSE
        end
      end
    end
  end
end
