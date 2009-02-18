module Rack
  module Mount
    module Mappers
      class RailsClassic
        def initialize(set)
          @set = set
        end

        def connect(path, options = {})
          @set.add_route(path, options)
        end
      end
    end
  end
end
