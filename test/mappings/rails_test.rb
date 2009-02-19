require 'test_helper'

class RailsApiTest < Test::Unit::TestCase
  include TestHelper
  include BasicRecognitionTests

  Routes = Rack::Mount::RouteSet.new
  Routes.draw do |map|
    map.connect "people", :app => Tracer.new(EchoApp, :people_index), :conditions => { :method => :get }
    map.connect "people", :app => Tracer.new(EchoApp, :people_create), :conditions => { :method => :post }
    map.connect "people/new", :app => Tracer.new(EchoApp, :people_new), :conditions => { :method => :get }
    map.connect "people/:id/edit", :app => Tracer.new(EchoApp, :people_edit), :conditions => { :method => :get }
    map.connect "people/:id", :app => Tracer.new(EchoApp, :people_show), :conditions => { :method => :get }
    map.connect "people/:id", :app => Tracer.new(EchoApp, :people_update), :conditions => { :method => :put }
    map.connect "people/:id", :app => Tracer.new(EchoApp, :people_delete), :conditions => { :method => :delete }

    map.connect "foo", :app => Tracer.new(EchoApp, :foo)
    map.connect "foo/bar", :app => Tracer.new(EchoApp, :foo_bar)
    map.connect "/baz", :app => Tracer.new(EchoApp, :baz)

    map.connect "files/*files", :app => Tracer.new(EchoApp, :files)
    map.connect ":controller/:action/:id", :app => Tracer.new(EchoApp, :default)
  end

  def setup
    @app = Routes
  end

  def test_worst_case
    # Make sure we aren't making the tree less efficient. Its okay if
    # this number gets smaller. However it may increase if the more
    # routes are added to the test fixture.
    assert_equal 8, Routes.worst_case
  end
end
