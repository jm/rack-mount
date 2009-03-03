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

      def initialize
        @default = Bucket.new
        super(@default)
      end

      def []=(key, *values)
        values.flatten!

        if key.nil?
          self << values.pop
        elsif values.length > 1
          super(key, NestedSet.new) unless has_key?(key)
          self[key][values.shift] = values
        elsif value = values.shift
          v = self[key]
          v = v.dup if v.equal?(@default)
          v << value
          super(key, v)
        end
      end

      def [](*keys)
        if keys.length > 1
          keys.inject(self) do |b, k|
            if b.is_a?(Array)
              return b
            else
              b[k]
            end
          end
        else
          super(*keys)
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
