module Rack
  module Mount
    module Mappers
      class Merb
        class Proxy
          def initialize
            @behaviors = []
          end

          def push(behavior)
            @behaviors.push(behavior)
          end

          def pop
            @behaviors.pop
          end

          def respond_to?(*args)
            super || @behaviors.last.respond_to?(*args)
          end

          %w(match to).each do |method|
            class_eval %{
              def #{method}(*args, &block)
                @behaviors.last.#{method}(*args, &block)
              end
            }
          end

          private
            def method_missing(method, *args, &block)
              behavior = @behaviors.last

              if behavior.respond_to?(method)
                behavior.send(method, *args, &block)
              else
                super
              end
            end
        end

        def initialize(set, proxy = nil, conditions = {})
          @set = set
          @proxy = proxy
          @conditions = conditions
        end

        def match(path, options = {})
          method = options.delete(:method)
          self.class.new(@set, @proxy, @conditions.merge(:path => path, :method => method))
        end

        def to(app)
          behavior = self.class.new(@set, @proxy, @conditions.merge(:app => app))
          behavior.to_route
        end

        protected
          def to_route
            method = @conditions.delete(:method)
            path = @conditions.delete(:path)
            @set.add_route(method, path, @conditions)
          end
      end
    end
  end
end
