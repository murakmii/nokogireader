# Nokogireader

DSL for parsing xml using Nokogiri::XML::Reader

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nokogireader'
```

## Example

```rb
class Rss2 < Nokogireader::Reader
  element :rss, attr: [:version] do
    element :channel do
      elements :item do
        element :title
        element :link
      end
    end
  end
end

data = Rss2.new.read(File.open('rss2.xml'))
puts "Version: #{data.rss.attributes[:version]}"
puts "Items: #{data.rss.channel.item.size}"
data.rss.channel.item.each do |item|
  puts " > #{item.title.text}"
end
```

You can use ``after`` callback and ``dont_store_data`` to reduce memory usage.

```rb
class Rss2 < Nokogireader::Reader
  element :rss, attr: [:version] do
    element :channel do
      elements :item do
        dont_store_data
        element :title
        element :link

        after do |reader, item|
          puts "Title: #{item.title.text}"
        end
      end
    end
  end
end

data = Rss2.new.read(File.open('rss2.xml'))
puts "Items: #{data.rss.channel.item.size}" # => 0. If specified "dont_store_data", data isn't stored.
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bonono/nokogireader.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
