module Rack
  module Mount
    class Bucket < Hash
      def initialize
        @default = []
        super(@default)
      end

      def []=(key, value)
        v = self[key]
        v = v.dup if v.equal?(@default)
        v << value
        super(key, v)
      end

      def <<(value)
        @default << value
        values.each { |e| e << value }
        nil
      end

      def freeze
        @default.freeze
        super
      end
    end
  end
end
