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
        requirements = options.delete(:requirements)

        @segment = @path.is_a?(Regexp) ?
          SegmentRegexp.new(@path, requirements) :
          SegmentString.new(@path, requirements)

        # Mark as dynamic only if the first segment is dynamic
        @dynamic = @segment.dynamic_first_segment?

        @recognizer = @segment.recognizer
        @params = @segment.params
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
          if @segment.is_a?(SegmentString)
            param_matches = path.scan(@segment.local_recognizer).flatten
            routing_args = {}
            @params.each_with_index { |p,i| routing_args[p] = param_matches[i] }
          elsif @segment.is_a?(SegmentRegexp)
            param_matches = Regexp.last_match.captures
            routing_args = {}
            @params.each_with_index { |p,i| routing_args[p] = param_matches[i] }
          end

          env["rack.routing_args"] = routing_args
          @app.call(env)
        else
          SKIP_RESPONSE
        end
      end
    end
  end
end
