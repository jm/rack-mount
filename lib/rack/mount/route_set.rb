module Rack
  module Mount
    class RouteSet
      attr_reader :max

      def initialize
        @routes = []
        @max = 100
      end

      def draw
        yield Mapper.new(self)
        freeze
      end

      def add_route(path, options = {})
        route = Route.new(self, options[:method], path, options[:app])
        @routes << route
        route
      end

      def freeze
        @buckets = build_tree(@max)
        super
      end

      def call(env)
        method = env["REQUEST_METHOD"]
        path = env["PATH_INFO"]
        @buckets.at(method, path).each do |route|
          result = route.call(env)
          return result unless result[0] == 404
        end
        nil
      end

      def worst_case
        @buckets.longest_child
      end

      private
        def build_tree(max)
          bucket = Bucket.new(@max)
          @routes.each do |route|
            max.times do |n|
              if route.hash?(n)
                bucket[n] << route
              end
            end
          end
          bucket
        end
    end
  end
end
