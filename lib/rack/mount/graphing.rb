module Rack
  module Mount
    module Graphing
      module ListHelper
        def to_graph_nodes
          %{node#{object_id} [label = "{ #{map { |value| value }.join("|")} }"];}
        end
      end

      module BucketHelper
        def to_graph_nodes
          graphs = []

          key_label = keys.map { |key| "<key#{key.object_id}> #{key}" }.join("|")
          graphs << %{node#{object_id} [label = "#{key_label}|<miss>", height=2.0];}

          graphs << "#{@default.to_graph_nodes}"
          graphs << "node#{object_id}:miss -> node#{@default.object_id};"

          each { |key, value|
            graphs << value.to_graph_nodes
            graphs << "node#{object_id}:key#{key.object_id} -> node#{value.object_id};"
          }

          graphs.flatten.join("\n  ")
        end

        def to_graph
          graph = <<-EOS
digraph G {
  nodesep=.05;
  rankdir=LR;
  node [shape=record,width=.1,height=.1];
  #{to_graph_nodes}
}
          EOS
        end
      end

      module RouteHelper
        def to_s
          "#{method} #{path}"
        end
      end
    end
  end
end
