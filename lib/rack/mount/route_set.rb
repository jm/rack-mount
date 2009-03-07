module Rack
  module Mount
    class RouteSet
      DEFAULT_OPTIONS = {
        :keys => [:method, :first_segment]
      }.freeze

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.dup.merge!(options)
        @keys = @options.delete(:keys)
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
        keys = @keys.map { |key| route.send(key) }
        @root[*keys] = route
        route
      end

      def call(env)
        env_str = Request.new(env)
        keys = @keys.map { |key| env_str.send(key) }
        @root[*keys].each do |route|
          result = route.call(env)
          return result unless result[0] == 404
        end
        nil
      end

      def freeze
        @root.freeze

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
