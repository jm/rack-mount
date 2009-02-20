require 'active_support/inflector'

module Rack
  module Mount
    module Mappers
      class RailsDraft
        def initialize(set)
          @set = set
        end

        def get(path, options = {})
          match(path, options.merge(:method => :get))
        end

        def post(path, options = {})
          match(path, options.merge(:method => :post))
        end

        def put(path, options = {})
          match(path, options.merge(:method => :put))
        end

        def delete(path, options = {})
          match(path, options.merge(:method => :delete))
        end

        def match(path, options = {})
          new_options = {}
          new_options[:path] = path
          new_options[:method] = options.delete(:method)
          new_options[:requirements] = options.delete(:constraints) || {}
          new_options[:defaults] = {}

          if to = options.delete(:to)
            controller, action = to.split("#")
            new_options[:defaults][:controller] = controller if controller
            new_options[:defaults][:action] = action if action
          end

          if new_options[:defaults].has_key?(:controller)
            app = "#{new_options[:defaults][:controller].camelize}Controller"
            app = ActiveSupport::Inflector.constantize(app)
            new_options[:app] = app
          else
            new_options[:app] = lambda { |env|
              app = "#{env["rack.routing_args"][:controller].camelize}Controller"
              app = ActiveSupport::Inflector.constantize(app)
              app.call(env)
            }
          end

          @set.add_route(new_options)
        end
      end
    end
  end
end
