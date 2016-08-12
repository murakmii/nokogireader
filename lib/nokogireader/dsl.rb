module Nokogireader
  # DSL to configure Nokogireader::Definition
  class DSL
    def initialize(definition)
      @definition = definition
    end
    
    def element(name, opts = {}, &block)
      @definition.children[name.to_s] = 
        create_child(opts, !block_given?).configure(&block)
    end

    def elements(name, opts = {}, &block)
      child = create_child(opts, !block_given?)
      child.multiple = true
      @definition.children[name.to_s] = child.configure(&block)
    end

    def after(method_name = nil, &block)
      @definition.after_callback = method_name || block
    end

    def dont_store_data
      @definition.dont_store_data = true
    end

    private

    def create_child(opts, accept_text)
      child = Definition.new
      child.accept_text = accept_text
      child.read_attributes = opts[:attr] if opts[:attr]
      child
    end
  end
end
