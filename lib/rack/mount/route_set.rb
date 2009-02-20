module Rack
  module Mount
    class RouteSet
      def initialize
        @routes = []
      end

      def draw
        yield Mappers::RailsClassic.new(self)
        freeze
      end

      def new_draw(&block)
        mapper = Mappers::RailsDraft.new(self)
        mapper.instance_eval(&block)
        freeze
      end

      def prepare(&block)
        proxy = Mappers::Merb::Proxy.new
        proxy.push(Mappers::Merb.new(self, proxy))
        proxy.instance_eval(&block)
        freeze
      end

      def add_route(options = {})
        route = Route.new(options)
        @routes << route
        route
      end

      def freeze
        @buckets = build_tree
        super
      end

      def call(env)
        method = env["REQUEST_METHOD"]
        path = env["PATH_INFO"]

        key = "#{method}#{path.slice(SegmentString::FIRST_SEGMENT_REGEXP)}"
        @buckets[key].each do |route|
          result = route.call(env)
          return result unless result[0] == 404
        end
        nil
      end

      def size
        @routes.length
      end

      def worst_case
        @buckets.values.max { |a, b| a.length <=> b.length }.length
      end

      private
        def build_tree
          bucket = Bucket.new
          @routes.each do |route|
            if route.dynamic?
              bucket << route
            else
              route.methods.each do |method|
                key = "#{method}#{route.path.slice(SegmentString::FIRST_SEGMENT_REGEXP)}"
                bucket[key] = route
              end
            end
          end
          bucket.freeze
        end
    end
  end
end
