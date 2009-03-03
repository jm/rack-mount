module Rack
  module Mount
    class Route
      include Graphing::RouteHelper

      SKIP_RESPONSE = [404, {"Content-Type" => "text/html"}, "Not Found"]
      HTTP_METHODS = ["GET", "HEAD", "POST", "PUT", "DELETE"]

      attr_reader :path, :method

      def initialize(options)
        @app = options.delete(:app)
        raise ArgumentError unless @app && @app.respond_to?(:call)

        method = options.delete(:method)
        @method = method.to_s.upcase if method

        @path = options.delete(:path)
        @requirements = options.delete(:requirements).freeze
        @defaults = options.delete(:defaults).freeze

        segment = @path.is_a?(Regexp) ?
          SegmentRegexp.new(@path, @requirements) :
          SegmentString.new(@path, @requirements)

        # Mark as dynamic only if the first segment is dynamic
        @dynamic = segment.dynamic_first_segment?
        @recognizer = segment.recognizer
        @params = segment.params
      end

      def dynamic?
        @dynamic
      end

      def call(env)
        method = env["REQUEST_METHOD"]
        path = env["PATH_INFO"]

        if (@method.nil? || method == @method) && path =~ @recognizer
          routing_args, param_matches = {}, $~.captures
          @params.each_with_index { |p,i| routing_args[p] = param_matches[i] }
          env["rack.routing_args"] = routing_args.merge!(@defaults)
          @app.call(env)
        else
          SKIP_RESPONSE
        end
      end
    end
  end
end
