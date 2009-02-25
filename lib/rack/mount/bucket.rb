module Rack
  module Mount
    class Bucket < Hash
      class List < Array
        include Graphing::ListHelper

        def [](key)
          raise ArgumentError, "no random access"
        end

        def freeze
          each { |e| e.freeze }
          super
        end
      end

      include Graphing::BucketHelper

      def initialize
        @default = List.new
        super(@default)
      end

      def []=(key, *values)
        values.flatten!

        if key.nil? && values.length == 1
          self << values.shift
        elsif values.length > 1
          super(key, Bucket.new) unless has_key?(key)
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

      def longest_value
        values.max { |a, b|
          a_len, b_len = a.length, b.length
          a_len = a.longest_value if a.respond_to?(:longest_value)
          b_len = b.longest_value if a.respond_to?(:longest_value)
          a_len <=> b_len
        }.length
      end
    end
  end
end
