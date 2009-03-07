require 'graphviz'

class GraphViz
  def self.to_node(obj)
    "node#{obj.object_id}"
  end

  def self.to_label(obj)
    case obj
    when true
      "true"
    when false
      "false"
    when nil
      "nil"
    when Array
      "{#{obj.map { |e| e.to_s }.join("|")}}"
    when Hash
      "#{obj.keys.map { |e|
        "<#{to_node(e)}> #{e.to_s}"
      }.join("|")}|<default>"
    when String
      obj.to_str
    else
      raise "unsupported class: #{obj.class}"
    end
  end

  def add_object(obj, options = {})
    options.merge!(:label => self.class.to_label(obj))

    case obj
    when Array
      add_node(self.class.to_node(obj), options)
    when Hash
      hash_node = add_node(self.class.to_node(obj), options)

      obj.each do |key, value|
        node = add_object(value)
        add_edge("#{hash_node.name}:#{self.class.to_node(key)}", node)
      end

      unless obj.default.nil?
        node = add_object(obj.default)
        add_edge("#{hash_node.name}:default", node)
      end

      hash_node
    when String
      add_node(self.class.to_node(obj), options)
    else
      raise "unsupported class: #{obj.class}"
    end
  end
end
