require 'rack/mount'

App = lambda { |env|
  [200, {"Content-Type" => "text/html"}, []]
}

Map = lambda do |map|
  resouces = ("a".."zz")

  resouces.each do |resouce|
    map.connect "#{resouce}", :method => :get, :app => App
    map.connect "#{resouce}", :method => :post, :app => App
    map.connect "#{resouce}/new", :method => :get, :app => App
    map.connect "#{resouce}/:id/edit", :method => :get, :app => App
    map.connect "#{resouce}/:id", :method => :get, :app => App
    map.connect "#{resouce}/:id", :method => :put, :app => App
    map.connect "#{resouce}/:id", :method => :delete, :app => App
  end
end

Env = {
  "REQUEST_METHOD" => "GET",
  "PATH_INFO" => "/zz/1"
}


def generate_set(n)
  set = Rack::Mount::RouteSet.new(n)
  set.draw(&Map)
  puts "  #{set.size}\t\t#{n}\t\t#{set.utilization}%\t\t#{set.worst_case}"
  set
end

puts "Building...\n"

puts " Routes\t\tBuckets\t\tUtilization\tWorst Case"
puts "==========================================================="
Bucket1Routes   = generate_set(1)
Bucket10Routes  = generate_set(10)
Bucket100Routes = generate_set(100)
Bucket500Routes = generate_set(500)

puts "\nRecognizing..."

require 'benchmark'

TIMES = 100.to_i

Benchmark.bmbm do |x|
  x.report("1 bucket")    { TIMES.times { Bucket1Routes.call(Env.dup) } }
  x.report("10 buckets")  { TIMES.times { Bucket10Routes.call(Env.dup) } }
  x.report("100 buckets") { TIMES.times { Bucket100Routes.call(Env.dup) } }
  x.report("500 buckets") { TIMES.times { Bucket500Routes.call(Env.dup) } }
end
