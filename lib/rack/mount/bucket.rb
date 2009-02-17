module Rack
  module Mount
    class Bucket < Array
      def self.hash(max, method, path)
        path.sub(/^\//, "").split("/")[0].hash % max
      end

      def initialize(max)
        @max = max
        @max.times { |n| self[n] = [] }
      end

      def freeze
        each { |e| e.freeze }
        super
      end

      def at(*keys)
        super(self.class.hash(@max, *keys))
      end

      def longest_child
        max { |a, b| a.length <=> b.length }.length
      end
    end
  end
end
