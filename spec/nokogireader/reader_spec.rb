require 'spec_helper'

describe Nokogireader::Reader do
  shared_examples 'an alias of DSL' do |method_name|
    it "calls #{method_name} of Definition" do
      root = described_class.root_definition

      dsl_mock = double(Nokogireader::DSL)
      expect(dsl_mock).to receive(method_name).with(:foo, attr: [:a])
      expect(Nokogireader::DSL).to receive(:new).with(root).and_return(dsl_mock)

      described_class.send(method_name, :foo, attr: [:a])
    end
  end

  describe '.element' do
    it_behaves_like 'an alias of DSL', :element
  end

  describe '.elements' do
    it_behaves_like 'an alias of DSL', :elements
  end

  describe '#read' do
    let(:xml) { File.open("spec/fixtures/xml/#{file_name}.xml") }
    let(:reader) { reader_class.new }
    subject { reader.read(xml) }
    
    describe 'book of simple.xml' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          elements :book do
            element :title
            element :page
            after :count_page
          end

          attr_reader :pages

          def initialize
            @pages = 0
          end

          def count_page(book)
            @pages += book[:page].text.to_i
          end
        end
      end

      it 'returns expected read data' do
        expect(subject[:book].size).to be 2
        expect(subject[:book].first['title'].text).to eq 'book 1'
        expect(subject[:book].last['title'].text).to eq 'book 2'
        expect(reader.pages).to be 384
      end
    end

    describe 'book of simple.xml(use "dont_store_data")' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          elements :book do
            dont_store_data
            element :title
            element :page
            after :count_page
          end

          attr_reader :pages

          def initialize
            @pages = 0
          end

          def count_page(book)
            @pages += book[:page].text.to_i
          end
        end
      end

      it 'returns expected read data' do
        expect(subject[:book].size).to be 0
        expect(reader.pages).to be 384
      end
    end

    describe 'books of simple.xml' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          element :books
        end
      end

      it 'returns expected read data' do
        expect(subject[:books]).to be_a(Nokogireader::ReadData)
        expect(subject[:books].text).to be_nil
      end
    end

    describe 'books of simple.xml(2)' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          element :books do
            element :metadata do
              element :books
            end
          end
        end
      end

      it 'returns expected read data' do
        expect(subject[:books][:metadata][:books]).to be_a(Nokogireader::ReadData)
        expect(subject[:books][:metadata][:books].text).to eq '2'
      end
    end

    describe 'date of simple.xml' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          element :date, attr: [:created_at]
        end
      end

      it 'returns expected read data' do
        expect(subject[:date]).to be_a(Nokogireader::ReadData)
        expect(subject[:date].attributes[:created_at]).to eq '2016-01-01'
      end
    end

    describe 'title of nested.xml' do
      let(:file_name) { 'nested' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          elements :title
        end
      end

      it 'returns expected read data' do
        expect(subject[:title].size).to be 2
        expect(subject[:title].first.text).to eq 'title 1'
        expect(subject[:title].last.text).to eq 'title 2'
      end
    end
  end
end
