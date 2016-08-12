module Nokogireader
  class Definition
    attr_reader :children
    attr_accessor :read_attributes, :after_callback, 
                  :accept_text, :multiple,
                  :dont_store_data

    def initialize
      @read_attributes = []
      @after_callback = nil
      @children = {}
      @accept_text = false
      @multiple = false
      @dont_store_data = false
    end

    def configure(&block)
      return self unless block_given?
      DSL.new(self).instance_eval(&block)
      self
    end

    def accept?(node)
      if node.node_type == 1
        @children.key?(node.name)
      elsif node.node_type == 3
        @accept_text
      else
        false
      end
    end
    
    def multiple?
      @multiple
    end

    def on_traversed(reader, data)
      return unless @after_callback
      if @after_callback.is_a?(Symbol)
        reader.send(@after_callback, data)
      else
        @after_callback.call(reader, data)
      end
    end
  end
end
