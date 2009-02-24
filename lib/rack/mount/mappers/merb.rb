require 'rack'
require 'active_support/inflector'
require 'merb-core/dispatch/router'

module Rack
  module Mount
    module Mappers
      class Merb
        class ::Merb::Router::Behavior
          def to_route
            raise Error, "The route has already been committed." if @route

            controller = @params[:controller]

            if prefixes = @options[:controller_prefix]
              controller ||= ":controller"

              prefixes.reverse_each do |prefix|
                break if controller =~ %r{^/(.*)} && controller = $1
                controller = "#{prefix}/#{controller}"
              end
            end

            @params.merge!(:controller => controller.to_s.gsub(%r{^/}, '')) if controller

            identifiers = @identifiers.sort { |(first,_),(sec,_)| first <=> sec || 1 }

            Thread.current[:merb_routes] << [
              @conditions.dup,
              @params,
              @blocks,
              { :defaults => @defaults.dup, :identifiers => identifiers }
            ]

            self
          end
        end

        class DeferredProc
          def initialize(app, deferred_procs)
            @app, @proc = app, deferred_procs.cache
          end

          def call(env)
            # TODO: Change this to a Merb request
            request = Rack::Request.new(env)
            params  = env["rack.routing_args"]
            result  = @proc.call(request, params)

            if result
              @app.call(env)
            else
              Route::SKIP_RESPONSE
            end
          end
        end

        attr_accessor :root_behavior

        def initialize(set)
          @set = set
          @root_behavior = ::Merb::Router::Behavior.new.defaults(:action => "index")
        end

        def prepare(first = [], last = [], &block)
          Thread.current[:merb_routes] = []
          root_behavior._with_proxy(&block)
          routes = Thread.current[:merb_routes]
          routes.each { |route| add_route(*route) }
          self
        ensure
          Thread.current[:merb_routes] = nil
        end

        def add_route(conditions, params, deferred_procs, options = {})
          new_options = {}
          new_options[:path] = conditions.delete(:path)[0]
          new_options[:method] = conditions.delete(:method)

          requirements = {}
          conditions.each do |k, v|
            if v.is_a?(Regexp) || new_options[:path].is_a?(Regexp)
              requirements[k.to_sym] = conditions.delete(k)
            end
          end

          new_options[:requirements] = requirements
          new_options[:defaults] = params

          if params.has_key?(:controller)
            app = ActiveSupport::Inflector.camelize("#{params[:controller]}Controller")
            app = ActiveSupport::Inflector.constantize(app)
            new_options[:app] = app
          else
            new_options[:app] = lambda { |env|
              app = ActiveSupport::Inflector.camelize("#{env["rack.routing_args"][:controller]}Controller")
              app = ActiveSupport::Inflector.constantize(app)
              app.call(env)
            }
          end

          if deferred_procs.any?
            new_options[:app] = DeferredProc.new(new_options[:app], deferred_procs.first)
          end

          @set.add_route(new_options)
        end
      end
    end
  end
end
