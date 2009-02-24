require 'rubygems'
require 'rack/mount'

FooController = lambda { |env|
  [200, {"Content-Type" => "text/html"}, []]
}

def Object.const_missing(name)
  if name.to_s =~ /Controller$/
    FooController
  else
    super
  end
end

Map = lambda do |map|
  resources = ("a".."zz")

  resources.each do |resource|
    map.resource resource.to_s
  end

  map.connect ":controller/:action/:id"
end

Env = {
  "REQUEST_METHOD" => "GET",
  "PATH_INFO" => "/zz/1"
}

Routes = Rack::Mount::RouteSet.new(:compactor => false)
Routes.draw(&Map)

require 'benchmark'

TIMES = 10_000.to_i

Benchmark.bmbm do |x|
  x.report("hash bucket") { TIMES.times { Routes.call(Env.dup) } }
end
