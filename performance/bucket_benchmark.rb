require 'rack/mount'

App = lambda { |env|
  [200, {"Content-Type" => "text/html"}, []]
}

Map = lambda do |map|
  resources = ("a".."zz")

  resources.each do |resouce|
    map.connect "#{resouce}", :method => :get, :app => App
    map.connect "#{resouce}", :method => :post, :app => App
    map.connect "#{resouce}/new", :method => :get, :app => App
    map.connect "#{resouce}/:id/edit", :method => :get, :app => App
    map.connect "#{resouce}/:id", :method => :get, :app => App
    map.connect "#{resouce}/:id", :method => :put, :app => App
    map.connect "#{resouce}/:id", :method => :delete, :app => App
  end

  map.connect ":controller/:action/:id", :app => App
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
