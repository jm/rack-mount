module Rack
  module Mount
    module Mappers
      autoload :Merb, 'rack/mount/mappers/merb'
      autoload :RailsClassic, 'rack/mount/mappers/rails_classic'
    end
  end
end
