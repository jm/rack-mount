module Rack
  module Mount
    module Mappers
      class RailsClassic
        def initialize(set)
          @set = set
        end

        def connect(path, options = {})
          options[:path] = path

          if conditions = options.delete(:conditions)
            options[:method] = conditions.delete(:method)
          end

          requirements = options[:requirements] ||= {}
          options.each do |k, v|
            if v.is_a?(Regexp)
              requirements[k.to_sym] = options.delete(k)
            end
          end

          @set.add_route(options)
        end
      end
    end
  end
end
