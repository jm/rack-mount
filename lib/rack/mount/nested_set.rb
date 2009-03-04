module Rack
  module Mount
    class NestedSet < Hash
      class Bucket < Array
        include Graphing::BucketHelper

        def [](key)
          raise ArgumentError, "no random access"
        end

        def freeze
          each { |e| e.freeze }
          super
        end
      end

      include Graphing::NestedSetHelper

      def initialize(default = Bucket.new)
        super(@default = default)
      end

      def []=(key, *values)
        values.flatten!

        if key.nil?
          self << values.pop
          return
        end

        v = self[key]
        v = v.dup if v.equal?(@default)

        if values.length > 1
          v = NestedSet.new(v) if v.is_a?(Bucket)
          v[values.shift] = values
        elsif value = values.shift
          v << value
        end

        super(key, v)
      end

      alias_method :at, :[]

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
        @default << value
        values.each { |e| e << value }
        nil
      end

      def freeze
        @default.freeze
        values.each { |v| v.freeze }
        super
      end

      def depth
        values.map { |v|
          v.is_a?(NestedSet) ? v.depth : v.length
        }.max { |a, b| a <=> b }
      end
    end
  end
end
