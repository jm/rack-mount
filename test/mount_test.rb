require 'test/unit'
require 'rack/mount'
require 'yaml'

class MountTest < Test::Unit::TestCase
  App = lambda { |env|
    [200, {"Content-Type" => "text/yaml"}, [YAML.dump(env)]]
  }

  Routes = Rack::Mount::RouteSet.new
  Routes.draw do |map|
    resouces = [:people, :companies]

    resouces.each do |resouce|
      map.connect "#{resouce}", :method => :get, :app => App
      map.connect "#{resouce}", :method => :post, :app => App
      map.connect "#{resouce}/new", :method => :get, :app => App
      map.connect "#{resouce}/:id/edit", :method => :get, :app => App
      map.connect "#{resouce}/:id", :method => :get, :app => App
      map.connect "#{resouce}/:id", :method => :put, :app => App
      map.connect "#{resouce}/:id", :method => :delete, :app => App
    end

    map.connect ":controller/:action/:id", :app => App
  end

  def test_routing
    env = process(:get, "/people")
    assert_equal({}, env["rack.routing_args"])

    env = process(:get, "/people/1")
    assert_equal({ :id => "1" }, env["rack.routing_args"])

    env = process(:get, "/people/2/edit")
    assert_equal({ :id => "2" }, env["rack.routing_args"])

    env = process(:get, "/companies/3")
    assert_equal({ :id => "3" }, env["rack.routing_args"])

    env = process(:get, "/foo/bar/1")
    assert_equal({ :controller => "foo", :action => "bar", :id => "1" },
      env["rack.routing_args"])

    assert_nil process(:get, "/widgets/3")
  end

  private
    def process(method, path)
      result = Routes.call({
        "REQUEST_METHOD" => method.to_s.upcase,
        "PATH_INFO" => path
      })

      if result
        YAML.load(result[2][0])
      else
        nil
      end
    end
end
