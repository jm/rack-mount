require 'rubygems'
require 'test/unit'
require 'yaml'

require 'rack/mount'

require 'basic_recognition_tests'

EchoApp = lambda { |env|
  [200, {"Content-Type" => "text/yaml"}, [YAML.dump(env)]]
}

def Object.const_missing(name)
  if name.to_s =~ /Controller$/
    EchoApp
  else
    super
  end
end

module TestHelper
  private
    def env
      @env
    end

    def get(path)
      process(:get, path)
    end

    def post(path)
      process(:post, path)
    end

    def put(path)
      process(:put, path)
    end

    def delete(path)
      process(:delete, path)
    end

    def process(method, path)
      result = @app.call({
        "REQUEST_METHOD" => method.to_s.upcase,
        "PATH_INFO" => path
      })

      if result
        @env = YAML.load(result[2][0])
      else
        @env = nil
      end
    end
end
