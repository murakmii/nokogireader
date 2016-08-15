module Nokogireader
  class Reader
    def self.root_definition
      @root ||= Definition.new
    end

    def self.element(name, opts = {}, &block)
      root_definition.configure do
        element(name, opts, &block)
      end
    end

    def read(xml)
      defstack = [self.class.root_definition]
      data = ReadData.new(nil, defstack.last, nil)

      build_xml_reader(xml).each do |n|
        if n.node_type == 1
          defstack << if defstack.last && defstack.last.accept?(n)
                        defstack.last.children[n.name]
                      end
          data = data.add_child(defstack.last, n) if defstack.last
        elsif n.node_type == 3
          data.text = n.value if defstack.last && defstack.last.accept?(n)
        end

        if (n.node_type == 15 || n.self_closing?) && (old_def = defstack.pop)
          old_def.on_traversed(self, data)
          data = data.parent 
          data.clear_child_for(n) if old_def.dont_store_data
        end
      end

      data
    end

    private

    def build_xml_reader(source)
      method_name = if source.kind_of?(IO) || source.kind_of?(StringIO)
                      :from_io
                    else
                      :from_memory
                    end

      ::Nokogiri::XML::Reader.send(method_name, source)
    end
  end
end
