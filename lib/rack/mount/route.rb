module Rack
  module Mount
    class Route
      def initialize(set, method, string, app)
        @set = set
        @method = method.to_s.upcase if method
        @app = app
        @string = string
        string.sub!(/^\//, "")

        # Mark as dynamic only if the first segment is dynamic
        @dynamic = (@string =~ /^:/) ? true : false

        @params = []
        local_segments = []

        segments = @string.split("/").map! { |segment|
          next if segment.empty?
          segment = local_segment = Regexp.escape(segment)

          if segment =~ /:\w+/
            segment_symbols = segment.scan(/:(\w+)/).flatten
            segment_symbols.each do |segment_symbol|
              @params << segment_symbol.to_sym
              local_segment = segment.gsub(/:#{segment_symbol}/, "(.*)")
              segment.gsub!(/:#{segment_symbol}/, ".*")
            end
          elsif segment =~ /^\*w+/
            @params << segment.to_sym
            local_segment = segment.gsub(/:#{segment_symbol}/, "(.*)")
            segment.gsub!(/:#{segment_symbol}/, ".*")
          end

          local_segments << local_segment
          segment
        }.compact

        @local_recognizer = Regexp.compile("#{local_segments.compact.join("\/")}")
        @recognizer = Regexp.compile("^/#{segments.join("\/")}$")
      end

      def hash?(n)
        @dynamic || Bucket.hash(@set.max, @method, @string) == n
      end

      def call(env)
        method = env["REQUEST_METHOD"]
        path = env["PATH_INFO"]

        if (@method.nil? || method == @method) && path =~ @recognizer
          param_matches = path.sub(/^\//, "").scan(@local_recognizer).flatten
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
