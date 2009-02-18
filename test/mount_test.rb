require 'test_helper'

class RailsApiTest < Test::Unit::TestCase
  include TestHelper

  Routes = Rack::Mount::RouteSet.new
  Routes.draw do |map|
    resources = [:people, :companies]

    resources.each do |resouce|
      map.connect "#{resouce}", :app => EchoApp, :conditions => { :method => :get }
      map.connect "#{resouce}", :app => EchoApp, :conditions => { :method => :post }
      map.connect "#{resouce}/new", :app => EchoApp, :conditions => { :method => :get }
      map.connect "#{resouce}/:id/edit", :app => EchoApp, :conditions => { :method => :get }
      map.connect "#{resouce}/:id", :app => EchoApp, :conditions => { :method => :get }
      map.connect "#{resouce}/:id", :app => EchoApp, :conditions => { :method => :put }
      map.connect "#{resouce}/:id", :app => EchoApp, :conditions => { :method => :delete }
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

    get "/people/new"
    assert_equal({}, env["rack.routing_args"])

    post "/people/new"
    assert_nil env

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

class MerbApiTest < Test::Unit::TestCase
  include TestHelper

  Router = Rack::Mount::RouteSet.new
  Router.prepare do
    resources = [:people, :companies]

    resources.each do |resouce|
      match("/#{resouce}", :method => :get).to(EchoApp)
      match("/#{resouce}", :method => :post).to(EchoApp)
      match("/#{resouce}/new", :method => :get).to(EchoApp)
      match("/#{resouce}/:id/edit", :method => :get).to(EchoApp)
      match("/#{resouce}/:id", :method => :get).to(EchoApp)
      match("/#{resouce}/:id", :method => :put).to(EchoApp)
      match("/#{resouce}/:id", :method => :delete).to(EchoApp)
    end

    match("files/*files").to(EchoApp)

    match(":controller/:action/:id").to(EchoApp)
  end

  def setup
    @app = Router
  end

  def test_routing
    get "/people"
    assert_equal({}, env["rack.routing_args"])

    get "/people/1"
    assert_equal({ :id => "1" }, env["rack.routing_args"])

    get "/people/2/edit"
    assert_equal({ :id => "2" }, env["rack.routing_args"])

    get "/people/new"
    assert_equal({}, env["rack.routing_args"])

    post "/people/new"
    assert_nil env

    get "/companies/3"
    assert_equal({ :id => "3" }, env["rack.routing_args"])

    get "/foo/bar/1"
    assert_equal({ :controller => "foo", :action => "bar", :id => "1" },
      env["rack.routing_args"])

    get "/widgets/3"
    assert_nil env
  end
end
