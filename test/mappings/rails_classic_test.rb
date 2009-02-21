require 'test_helper'

class RailsClassicApiTest < Test::Unit::TestCase
  include TestHelper
  include BasicRecognitionTests

  Routes = Rack::Mount::RouteSet.new
  Routes.draw do |map|
    map.connect "people", :controller => "people", :action => "index", :conditions => { :method => :get }
    map.connect "people", :controller => "people", :action => "create", :conditions => { :method => :post }
    map.connect "people/new", :controller => "people", :action => "new", :conditions => { :method => :get }
    map.connect "people/:id/edit", :controller => "people", :action => "edit", :conditions => { :method => :get }
    map.connect "people/:id", :controller => "people", :action => "show", :id => /\d+/, :conditions => { :method => :get }
    map.connect "people/:id", :controller => "people", :action => "update", :requirements => { :id => /\d+/ }, :conditions => { :method => :put }
    map.connect "people/:id", :controller => "people", :action => "destroy", :requirements => { :id => /\d+/ }, :conditions => { :method => :delete }

    map.connect '', :controller => 'homepage'

    map.geocode 'geocode/:postalcode', :controller => 'geocode',
                 :action => 'show', :postalcode => /\d{5}(-\d{4})?/
    map.geocode2 'geocode2/:postalcode', :controller => 'geocode',
                 :action => 'show', :requirements => { :postalcode => /\d{5}(-\d{4})?/ }

    map.connect "foo", :controller => "foo", :action => "index"
    map.connect "foo/bar", :controller => "foo_bar", :action => "index"
    map.connect "/baz", :controller => "baz", :action => "index"

    map.connect "files/*files", :controller => "files", :action => "index"

    map.connect ':controller/:action/:id'
    map.connect ':controller/:action/:id.:format'
  end

  def setup
    @app = Routes
  end
end
