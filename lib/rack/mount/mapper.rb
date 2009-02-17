module Rack
  module Mount
    class Mapper
      def initialize(set)
        @set = set
      end

      def connect(path, options = {})
        @set.add_route(path, options)
      end
    end
  end
end
