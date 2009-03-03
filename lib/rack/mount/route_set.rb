module Rack
  module Mount
    class RouteSet
      include GarbageCompactor

      DEFAULT_OPTIONS = {
        :compactor => true
      }.freeze

      KEYS = [:method, :first_segment]

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.dup.merge!(options)
        @root = NestedSet.new
      end

      def draw(&block)
        Mappers::RailsClassic.new(self).draw(&block)
        freeze
      end

      def new_draw(&block)
        mapper = Mappers::RailsDraft.new(self)
        mapper.instance_eval(&block)
        freeze
      end

      def prepare(*args, &block)
        Mappers::Merb.new(self).prepare(*args, &block)
        freeze
      end

      def add_route(options = {})
        route = Route.new(options)
        each_key_from_route(route) do |method, first_segment|
          @root[method, first_segment] = route
        end
        route
      end

      def call(env)
        method, first_segment = key_from_env(env)
        bucket_or_hash = @root[method, first_segment]
        bucket_or_hash.each do |route|
          result = route.call(env)
          return result unless result[0] == 404
        end
        nil
      end

      def key_from_env(env)
        method = env["REQUEST_METHOD"]
        path = env["PATH_INFO"]
        first_segment = path.slice(SegmentString::FIRST_SEGMENT_REGEXP)
        return method, first_segment
      end

      def each_key_from_route(route)
        first_segment = route.dynamic? ? nil :
          route.path.slice(SegmentString::FIRST_SEGMENT_REGEXP)
        yield route.method, first_segment
      end

      def freeze
        @root.freeze
        # compact! if @options[:compactor]

        super
      end

      def worst_case
        @root.depth
      end

      def to_graph
        @root.to_graph
      end
    end
  end
end
