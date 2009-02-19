require 'test_helper'

class MerbApiTest < Test::Unit::TestCase
  include TestHelper
  include BasicRecognitionTests

  Router = Rack::Mount::RouteSet.new
  Router.prepare do
    match("/people", :method => :get).to(Tracer.new(EchoApp, :people_index))
    match("/people", :method => :post).to(Tracer.new(EchoApp, :people_create))
    match("/people/new", :method => :get).to(Tracer.new(EchoApp, :people_new))
    match("/people/:id/edit", :method => :get).to(Tracer.new(EchoApp, :people_edit))
    match("/people/:id", :id => /\d+/, :method => :get).to(Tracer.new(EchoApp, :people_show))
    match("/people/:id", :id => /\d+/, :method => :put).to(Tracer.new(EchoApp, :people_update))
    match("/people/:id", :id => /\d+/, :method => :delete).to(Tracer.new(EchoApp, :people_delete))

    match("foo").to(Tracer.new(EchoApp, :foo))
    match("foo/bar").to(Tracer.new(EchoApp, :foo_bar))
    match("/baz").to(Tracer.new(EchoApp, :baz))

    match(%r{^/regexp/foos?/(bar|baz)/([a-z0-9]+)}, :action => "[1]", :id => "[2]").to(Tracer.new(EchoApp, :regexp))

    match("files/*files").to(Tracer.new(EchoApp, :files))
    match(":controller/:action/:id").to(Tracer.new(EchoApp, :default))
  end

  def setup
    @app = Router
  end

  def test_regexp
    get "/regexp/foo/bar/baz"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({:action => "bar", :id => "baz"}, env["rack.routing_args"])
    assert_equal(:regexp, env["tracer"])

    get "/regexp/foos/bar/baz"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({:action => "bar", :id => "baz"}, env["rack.routing_args"])
    assert_equal(:regexp, env["tracer"])

    get "/regexp/bars/foo/baz"
    assert_nil env
  end
end
