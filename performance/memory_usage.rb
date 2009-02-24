require 'rubygems'
require 'rack/mount'
require 'ruby-prof'

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
  ("a".."z").each do |resource|
    map.resource resource.to_s
  end

  map.connect ":controller/:action/:id"
end

Env = {
  "REQUEST_METHOD" => "GET",
  "PATH_INFO" => "/z/1"
}

routes = Rack::Mount::RouteSet.new
routes.draw(&Map)


RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  routes.call(Env.dup)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)
