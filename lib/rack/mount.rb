module Rack
  module Mount
    SKIP_RESPONSE = [404, {"Content-Type" => "text/html"}, "Not Found"]

    autoload :Bucket, 'rack/mount/bucket'
    autoload :Mapper, 'rack/mount/mapper'
    autoload :Route, 'rack/mount/route'
    autoload :RouteSet, 'rack/mount/route_set'
  end
end
