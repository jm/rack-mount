require 'rubygems'
require 'rack/mount'

Set = Rack::Mount::NestedSet.new
("a".."z").each do |level1|
  ("a".."z").each do |level2|
    ("a".."z").each do |level3|
      Set[level1, level2, level3] = "#{level1}:#{level2}:#{level3}"
    end
    Set[level1, level2] = "#{level1}:#{level2}:?"
  end
  Set[level1] = "#{level1}:?:?"
end

require 'benchmark'

TIMES = 100_000.to_i

Benchmark.bmbm do |x|
  x.report("match 3 levels (hit)")  { TIMES.times { Set["a", "a", "a"] } }
  x.report("match 3 levels (miss)") { TIMES.times { Set["a", "a", "!"] } }

  x.report("match 2 levels (hit)")  { TIMES.times { Set["a", "a"] } }
  x.report("match 2 levels (miss)") { TIMES.times { Set["a", "!"] } }

  x.report("match 1 level (hit)")  { TIMES.times { Set["a"] } }
  x.report("match 1 level (miss)") { TIMES.times { Set["!"] } }
end
