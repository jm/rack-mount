module Rack
  module Mount
    class RouteSet
      def initialize
        @routes = []
      end

      def draw
        yield Mapper.new(self)
        freeze
      end

      def add_route(path, options = {})
        route = Route.new(options[:method], path, options[:app])
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
        @buckets[Route.first_segment(path)].each do |route|
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
              bucket[route.key] = route
            end
          end
          bucket.freeze
        end
    end
  end
end
