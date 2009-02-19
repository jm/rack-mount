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
    match("/people/:id", :method => :get).to(Tracer.new(EchoApp, :people_show))
    match("/people/:id", :method => :put).to(Tracer.new(EchoApp, :people_update))
    match("/people/:id", :method => :delete).to(Tracer.new(EchoApp, :people_delete))

    match("foo").to(Tracer.new(EchoApp, :foo))
    match("foo/bar").to(Tracer.new(EchoApp, :foo_bar))
    match("/baz").to(Tracer.new(EchoApp, :baz))

    match("files/*files").to(Tracer.new(EchoApp, :files))
    match(":controller/:action/:id").to(Tracer.new(EchoApp, :default))
  end

  def setup
    @app = Router
  end
end
