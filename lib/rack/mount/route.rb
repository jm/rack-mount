module Rack
  module Mount
    class Route
      SKIP_RESPONSE = [404, {"Content-Type" => "text/html"}, "Not Found"]
      SEPARATORS = %w( / . ? )

      def self.first_segment(path)
        path.sub(/^\//, "").split("/")[0]
      end

      def initialize(options)
        @app = options.delete(:app)
        raise ArgumentError unless @app && @app.respond_to?(:call)

        method = options.delete(:method)
        @method = method.to_s.upcase if method

        @path = options.delete(:path)
        @path.sub!(/^\//, "")

        requirements = options.delete(:requirements) || {}

        @params = []
        local_segments = []

        segments = @path.split("/").map! { |segment|
          next if segment.empty?
          segment = local_segment = Regexp.escape(segment)

          if segment =~ /^:(\w+)$/
            @params << $1.to_sym
            local_segment = "(#{requirements[$1.to_sym] || "[^#{SEPARATORS.join}]+"})"
            segment.gsub!(segment, "#{requirements[$1.to_sym] || "[^#{SEPARATORS.join}]+"}")
          elsif segment =~ /^\\\*(\w+)$/
            @params << $1.to_sym
            local_segment = "(.*)"
            segment.gsub!(segment, ".*")
          end

          local_segments << local_segment
          segment
        }

        # Mark as dynamic only if the first segment is dynamic
        @dynamic = segments[0] =~ /[\^\/\.\?]/ ? true : false

        @local_recognizer = Regexp.compile("#{local_segments.compact.join("\/")}")
        @recognizer = Regexp.compile("^/#{segments.compact.join("\/")}$")
      end

      def dynamic?
        @dynamic
      end

      def key
        Route.first_segment(@path)
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
