require 'rubygems'
require 'rack/mount'

FooController = lambda { |env|
  [200, {"Content-Type" => "text/html"}, []]
}

Map = lambda do |map|
  resources = ("a".."zz")

  resources.each do |resouce|
    map.connect "#{resouce}", :controller => "foo", :conditions => { :method => :get }
    map.connect "#{resouce}", :controller => "foo", :conditions => { :method => :post }
    map.connect "#{resouce}/new", :controller => "foo", :conditions => { :method => :get }
    map.connect "#{resouce}/:id/edit", :controller => "foo", :conditions => { :method => :get }
    map.connect "#{resouce}/:id", :controller => "foo", :conditions => { :method => :get }
    map.connect "#{resouce}/:id", :controller => "foo", :conditions => { :method => :put }
    map.connect "#{resouce}/:id", :controller => "foo", :conditions => { :method => :delete }
  end

  map.connect ":controller/:action/:id"
end

Env = {
  "REQUEST_METHOD" => "GET",
  "PATH_INFO" => "/zz/1"
}

Routes = Rack::Mount::RouteSet.new
Routes.draw(&Map)

require 'benchmark'

TIMES = 10_000.to_i

Benchmark.bmbm do |x|
  x.report("hash bucket") { TIMES.times { Routes.call(Env.dup) } }
end
