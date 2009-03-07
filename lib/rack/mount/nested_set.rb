module Rack
  module Mount
    class NestedSet < Hash
      class Bucket < Array
        def [](key)
          raise ArgumentError, "no random access"
        end

        def freeze
          each { |e| e.freeze }
          super
        end
      end

      def initialize(default = Bucket.new)
        super(default)
      end

      alias_method :at, :[]

      def []=(*args)
        args.flatten!
        value = args.pop
        key   = args.shift
        keys  = args

        raise ArgumentError, "missing value" unless value

        v = at(key)
        v = v.dup if v.equal?(default)

        if key.nil?
          if keys.empty?
            self << value
          else
            values.each do |v|
              v[keys] = value
            end
            default << value
          end
        else
          if keys.empty?
            v << value
          else
            v = NestedSet.new(v) if v.is_a?(Bucket)
            v[*keys] = value
          end
          super(key, v)
        end
      end

      def [](*keys)
        keys.inject(self) do |b, k|
          if b.is_a?(Array)
            return b
          else
            b.at(k)
          end
        end
      end

      def <<(value)
        default << value
        values.each { |e| e << value }
        nil
      end

      def values_with_default
        values.push(default)
      end

      def inspect
        super.gsub(/\}$/, ", nil => #{default.inspect}}")
      end

      def freeze
        values_with_default.each { |v| v.freeze }
        super
      end

      def depth
        values_with_default.map { |v|
          v.is_a?(NestedSet) ? v.depth : v.length
        }.max { |a, b| a <=> b }
      end

      def to_graph
        require 'rack/mount/graphviz_ext'

        g = GraphViz::new("G")
        g[:nodesep] = ".05"
        g[:rankdir] = "LR"

        g.node[:shape] = "record"
        g.node[:width] = ".1"
        g.node[:height] = ".1"

        g.add_object(self)

        g
      end
    end
  end
end
