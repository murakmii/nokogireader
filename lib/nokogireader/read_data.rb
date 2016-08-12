module Nokogireader
  class ReadData
    attr_accessor :text
    attr_reader :parent

    def initialize(parent_data, definition, node)
      @parent = parent_data
      @definition = definition
      @definition.read_attributes.each do |a|
        attributes[a] = node.attribute(a.to_s)
      end
    end

    def attributes
      @attributes ||= {}
    end

    def children
      @children ||= {}
    end

    def add_child(definition, node)
      child = self.class.new(self, definition, node)
      if definition.multiple?
        (children[node.name] ||= []) << child
      else
        children[node.name] = child
      end
      child
    end

    def clear_child_for(node)
      if children[node.name].is_a?(Array)
        children[node.name].pop
      else
        children.delete(node.name)
      end
    end

    def [](child_name)
      children[child_name.to_s]
    end
  end
end
