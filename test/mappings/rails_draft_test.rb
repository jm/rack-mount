require 'test_helper'

class RailsDraftApiTest < Test::Unit::TestCase
  include TestHelper
  include BasicRecognitionTests

  Routes = Rack::Mount::RouteSet.new
  Routes.new_draw do |map|
    get    'people', :to => 'people#index'
    post   'people', :to => 'people#create'
    get    'people/new', :to => 'people#new'
    get    'people/:id/edit', :to => 'people#edit', :constraints => { :id => /\d+/ }
    get    'people/:id', :to => 'people#show', :constraints => { :id => /\d+/ }
    put    'people/:id', :to => 'people#update', :constraints => { :id => /\d+/ }
    delete 'people/:id', :to => 'people#destroy', :constraints => { :id => /\d+/ }

    match '', :to => 'homepage'

    match 'geocode/:postalcode',  :to => 'geocode#show', :as => :geocode, :constraints => { :postalcode => /\d{5}(-\d{4})?/ }
    match 'geocode2/:postalcode', :to => 'geocode#show', :as => :geocode, :constraints => { :postalcode => /\d{5}(-\d{4})?/ }

    match 'foo', :to => 'foo#index'
    match 'foo/bar', :to => 'foo_bar#index'
    match '/baz', :to => 'baz#index'

    match 'files/*files', :to => 'files#index'

    match ':controller/:action/:id'
    match ':controller/:action/:id.:format'
  end

  def setup
    @app = Routes
  end
end
