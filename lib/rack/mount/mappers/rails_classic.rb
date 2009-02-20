require 'active_support/inflector'

module Rack
  module Mount
    module Mappers
      class RailsClassic
        def initialize(set)
          @set = set
        end

        def connect(path, options = {})
          new_options = {}
          new_options[:path] = path

          if conditions = options.delete(:conditions)
            new_options[:method] = conditions.delete(:method)
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

          new_options[:requirements] = requirements
          new_options[:defaults] = defaults

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

        def method_missing(route_name, *args, &block) #:nodoc:
          super unless args.length >= 1 && block.nil?
          connect(*args)
        end
      end
    end
  end
end
