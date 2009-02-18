require 'test/unit'
require 'rack/mount'
require 'yaml'

class MountTest < Test::Unit::TestCase
  App = lambda { |env|
    [200, {"Content-Type" => "text/yaml"}, [YAML.dump(env)]]
  }

  Routes = Rack::Mount::RouteSet.new
  Routes.draw do |map|
    resources = [:people, :companies]

    resources.each do |resouce|
      map.connect "#{resouce}", :method => :get, :app => App
      map.connect "#{resouce}", :method => :post, :app => App
      map.connect "#{resouce}/new", :method => :get, :app => App
      map.connect "#{resouce}/:id/edit", :method => :get, :app => App
      map.connect "#{resouce}/:id", :method => :get, :app => App
      map.connect "#{resouce}/:id", :method => :put, :app => App
      map.connect "#{resouce}/:id", :method => :delete, :app => App
    end

    map.connect "files/*files", :app => App

    map.connect ":controller/:action/:id", :app => App
  end

  def test_routing
    get "/people"
    assert_equal({}, env["rack.routing_args"])

    get "/people/1"
    assert_equal({ :id => "1" }, env["rack.routing_args"])

    get "/people/2/edit"
    assert_equal({ :id => "2" }, env["rack.routing_args"])

    get "/companies/3"
    assert_equal({ :id => "3" }, env["rack.routing_args"])

    get "/files/images/photo.jpg"
    # TODO
    # assert_equal({:files => ["images", "photo.jpg"]}, env["rack.routing_args"])
    assert_equal({:files => "images/photo.jpg"}, env["rack.routing_args"])

    get "/foo/bar/1"
    assert_equal({ :controller => "foo", :action => "bar", :id => "1" },
      env["rack.routing_args"])

    get "/widgets/3"
    assert_nil env
  end

  def test_worst_case
    # Make sure we aren't making the tree less efficient. Its okay if
    # this number gets smaller. However it may increase if the more
    # routes are added to the test fixture.
    assert_equal 8, Routes.worst_case
  end

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
      result = Routes.call({
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
