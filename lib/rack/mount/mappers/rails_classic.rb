module Rack
  module Mount
    module Mappers
      class RailsClassic
        def initialize(set)
          @set = set
        end

        def connect(path, options = {})
          if conditions = options.delete(:conditions)
            method = conditions.delete(:method)
          end

          @set.add_route(method, path, options)
        end
      end
    end
  end
end
