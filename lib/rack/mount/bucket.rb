module Rack
  module Mount
    class Bucket < Hash
      DEFAULT_INDEX = nil.hash

      class HashProxy
        attr_reader :hash, :target

        def initialize(hash, target)
          @hash, @target = hash, target
        end
      end

      class QueryKey
        attr_accessor :hash, :matched

        def initialize(key, value)
          @hash, @value = key.hash, value
        end

        def eql?(proxy)
          @matched = true
          @value.eql?(proxy.target)
        end

        def at_default_index
          key = dup
          key.hash = DEFAULT_INDEX
          key
        end
      end

      def initialize
        @buffer = {}
        super
      end

      def lookup(hash, key)
        self[QueryKey.new(hash, key)]
      end

      def [](key)
        raise TypeError unless frozen?

        value = super

        # No elements at index, check default index
        unless key.matched
          value = super(key.at_default_index)
        end

        value ? value.target : nil
      end

      def []=(key, value)
        @buffer[key] ||= []

        if key.nil?
          @buffer.values.each { |e| e << value }
        else
          @buffer[key] << value
        end
      end

      def freeze
        @buffer.each do |key, values|
          values.reverse.each do |value|
            value = HashProxy.new(key.hash, value)
            store(value, value)
          end
        end
        @buffer = nil

        super
      end
    end
  end
end
