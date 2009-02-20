require 'test_helper'

class MerbApiTest < Test::Unit::TestCase
  include TestHelper
  include BasicRecognitionTests

  Router = Rack::Mount::RouteSet.new
  Router.prepare do
    match("/people", :method => :get).to(:controller => "people", :action => "index")
    match("/people", :method => :post).to(:controller => "people", :action => "create")
    match("/people/new", :method => :get).to(:controller => "people", :action => "new")
    match("/people/:id/edit", :method => :get).to(:controller => "people", :action => "edit")
    match("/people/:id", :id => /\d+/, :method => :get).to(:controller => "people", :action => "show")
    match("/people/:id", :id => /\d+/, :method => :put).to(:controller => "people", :action => "update")
    match("/people/:id", :id => /\d+/, :method => :delete).to(:controller => "people", :action => "destroy")

    match("").to(:controller => "homepage")

    match("foo").to(:controller => "foo", :action => "index")
    match("foo/bar").to(:controller => "foo_bar", :action => "index")
    match("/baz").to(:controller => "baz", :action => "index")

    match(%r{^/regexp/foos?/(bar|baz)/([a-z0-9]+)}, :action => "[1]", :id => "[2]").to(:controller => "foo")

    match("files/*files").to(:controller => "files", :action => "index")
    match(":controller/:action/:id").to()
    match(":controller/:action/:id.:format").to()
  end

  def setup
    @app = Router
  end

  def test_regexp
    get "/regexp/foo/bar/baz"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "bar", :id => "baz" }, env["rack.routing_args"])

    get "/regexp/foos/bar/baz"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "bar", :id => "baz" }, env["rack.routing_args"])

    get "/regexp/bars/foo/baz"
    assert_nil env
  end
end
