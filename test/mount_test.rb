require 'test_helper'

class MountTest < Test::Unit::TestCase
  include TestHelper

  Routes = Rack::Mount::RouteSet.new
  Routes.draw do |map|
    resources = [:people, :companies]

    resources.each do |resouce|
      map.connect "#{resouce}", :method => :get, :app => EchoApp
      map.connect "#{resouce}", :method => :post, :app => EchoApp
      map.connect "#{resouce}/new", :method => :get, :app => EchoApp
      map.connect "#{resouce}/:id/edit", :method => :get, :app => EchoApp
      map.connect "#{resouce}/:id", :method => :get, :app => EchoApp
      map.connect "#{resouce}/:id", :method => :put, :app => EchoApp
      map.connect "#{resouce}/:id", :method => :delete, :app => EchoApp
    end

    map.connect "files/*files", :app => EchoApp

    map.connect ":controller/:action/:id", :app => EchoApp
  end

  def setup
    @app = Routes
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
end
