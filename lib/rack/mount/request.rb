module Rack
  module Mount
    class Request < Bucket::QueryKey
      attr_reader :env

      def initialize(env = {})
        @env = env
        method, path = env["REQUEST_METHOD"], env["PATH_INFO"]
        key = "#{method} /#{path.slice(SegmentString::FIRST_SEGMENT_REGEXP)}"
        super(key, env)
      end

      def eql?(proxy)
        @matched = true
        route = proxy.target
        result = route.call(@env)
        if result[0] == 404
          false
        else
          Thread.current[:result] = result
          true
        end
      end
    end
  end
end
