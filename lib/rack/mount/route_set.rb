module Rack
  module Mount
    class RouteSet < Bucket
      include GarbageCompactor

      DEFAULT_OPTIONS = {
        :compactor => true
      }.freeze

      def initialize(options = {})
        @options = DEFAULT_OPTIONS.dup.merge!(options)
        super()
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

        if route.dynamic?
          self << route
        else
          path = route.path.slice(SegmentString::FIRST_SEGMENT_REGEXP)
          route.methods.each do |method|
            self["#{method} /#{path}"] = route
          end
        end

        route
      end

      def call(env)
        method = env["REQUEST_METHOD"]
        path = env["PATH_INFO"]

        key = "#{method} /#{path.slice(SegmentString::FIRST_SEGMENT_REGEXP)}"
        self[key].each do |route|
          result = route.call(env)
          return result unless result[0] == 404
        end
        nil
      end

      def freeze
        compact! if @options[:compactor]

        super
      end

      def worst_case
        values.max { |a, b| a.length <=> b.length }.length
      end

      def to_graph
        graph = <<-EOS
digraph G {
  nodesep=.05;
  rankdir=LR;
  node [shape=record,width=.1,height=.1];

  node0 [label = "#{keys.map { |k| "<k#{k.object_id}> #{k}" }.join("|")}",height=2.0];

  node [width = 1.5];
  #{
    values.map { |v|
      "node#{v.object_id} [label = \"{<n> #{v.map { |v| " /#{v.path} " }.join("|")} }\"];"
    }.join("\n  ")
  }

  #{
    map { |k, v|
      "node0:k#{k.object_id} -> node#{v.object_id}:n;"
    }.join("\n  ")
  }
}
        EOS
      end
    end
  end
end
