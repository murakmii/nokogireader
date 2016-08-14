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

  describe '#read' do
    let(:xml) { File.open("spec/fixtures/xml/#{file_name}.xml") }
    let(:reader) { reader_class.new }
    subject { reader.read(xml) }

    describe 'date of simple.xml' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          element :books do
            element :metadata do
              element :date, attr: [:created_at]
            end
          end
        end
      end

      it do
        expect(
          subject.books.metadata.date.attributes[:created_at]
        ).to eq '2016-01-01'
      end
    end

    describe 'book of simple.xml' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          element :books do
            elements :book do
              element :title
              element :page
            end
          end
        end
      end

      it do
        expect(subject.books.book.size).to be 2
        expect(subject.books.book.first.title.text).to eq 'book 1'
        expect(subject.books.book.last.title.text).to eq 'book 2'
      end
    end

    describe 'book of simple.xml(2)' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          element :book
        end
      end

      it do
        expect(subject.children).to be_empty
      end
    end

    describe 'total pages of simple.xml' do
      let(:file_name) { 'simple' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          element :books do
            elements :book do
              dont_store_data
              element :page
              after do |reader, book|
                reader.pages += book.page.text.to_i
              end
            end
          end

          attr_accessor :pages
          def initialize
            @pages = 0
          end
        end
      end

      it do
        expect(subject.books.book).to be_empty
        expect(reader.pages).to be 384
      end
    end

    describe 'title of nested.xml' do
      let(:file_name) { 'nested' }
      let(:reader_class) do
        Class.new(Nokogireader::Reader) do
          element :item do
            element :item do
              element :title
            end
          end
        end
      end

      it do
        expect(subject.item.item.title.text).to eq 'title 1'
      end
    end
  end
end
