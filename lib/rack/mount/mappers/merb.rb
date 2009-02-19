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

        def match(path, conditions = {})
          conditions[:path] = path

          requirements = conditions[:requirements] ||= {}
          conditions.each do |k, v|
            if v.is_a?(Regexp)
              requirements[k.to_sym] = conditions.delete(k)
            end
          end

          self.class.new(@set, @proxy, @conditions.merge(conditions))
        end

        def to(app)
          behavior = self.class.new(@set, @proxy, @conditions.merge(:app => app))
          behavior.to_route
        end

        protected
          def to_route
            @set.add_route(@conditions)
          end
      end
    end
  end
end
