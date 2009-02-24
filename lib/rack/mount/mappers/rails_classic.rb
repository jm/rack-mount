module Rack
  module Mount
    module Mappers
      class RailsClassic
        attr_reader :named_routes

        def initialize(set)
          @set = set
          @named_routes = {}
        end

        def draw(&block)
          require 'action_controller'
          yield ActionController::Routing::RouteSet::Mapper.new(self)
        end

        def add_route(path, options = {})
          if conditions = options.delete(:conditions)
            method = conditions.delete(:method)
          end

          requirements = options.delete(:requirements) || {}
          defaults = {}
          options.each do |k, v|
            if v.is_a?(Regexp)
              requirements[k.to_sym] = options.delete(k)
            else
              defaults[k.to_sym] = options.delete(k)
            end
          end

          if defaults.has_key?(:controller)
            app = "#{defaults[:controller].camelize}Controller"
            app = ActiveSupport::Inflector.constantize(app)
          else
            app = lambda { |env|
              app = "#{env["rack.routing_args"][:controller].camelize}Controller"
              app = ActiveSupport::Inflector.constantize(app)
              app.call(env)
            }
          end

          @set.add_route({
            :app => app,
            :path => path,
            :method => method,
            :requirements => requirements,
            :defaults => defaults
          })
        end

        def add_named_route(name, path, options = {})
          add_route(path, options)
        end
      end
    end
  end
end
