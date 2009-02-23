module Rack
  module Mount
    module GarbageCompactor
      def duplicate_buckets
        i = 0
        values.each do |v1|
          values.each do |v2|
            if v1.eql?(v2) && !v1.equal?(v2)
              i += 1
            end
          end
        end
        i
      end

      def compact!
        h = {}
        each do |k1, v1|
          each do |k2, v2|
            if v1.eql?(v2) && !v1.equal?(v2)
              h[k1] = v1
              h[k2] = v1
            end
          end
        end
        merge!(h)
        nil
      end
    end
  end
end
