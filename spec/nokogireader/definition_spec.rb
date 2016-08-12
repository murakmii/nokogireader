require 'spec_helper'

describe Nokogireader::Definition do
  let(:definition) { described_class.new }

  describe '#initialize' do
    its(:read_attributes) { should eq [] }
    its(:after_callback) { should be_nil }
    its(:children) { should eq({ }) }
    its(:accept_text) { should be_falsy }
    its(:multiple) { should be_falsy }
    its(:dont_store_data) { should be_falsy }
  end

  describe '#configure' do
    context 'when not passed block' do
      it 'do nothing' do
        expect(Nokogireader::DSL).not_to receive(:new)
        definition.configure
      end
    end

    context 'when passed block' do
      it 'applies block' do
        expect do
          definition.configure { dont_store_data }
            .to change { definition.dont_store_data }.from(false).to(true)
        end
      end
    end
  end

  describe '#accept?' do
    let(:node_stub) do
      node = double(::Nokogiri::XML::Reader)
      allow(node).to receive(:node_type).and_return node_type
      allow(node).to receive(:name).and_return 'foo'
      node
    end

    subject { definition.accept?(node_stub) }

    context 'when node is element' do
      let(:node_type) { 1 }
      context 'and no child definition' do
        it { is_expected.to be_falsy }
      end

      context 'and defined child' do
        before { definition.configure { element :foo } }
        it { is_expected.to be_truthy }
      end
    end

    context 'when node is text' do
      let(:node_type) { 3 }
      context "and doesn't accept text" do
        it { is_expected.to be_falsy }
      end

      context 'and accept text' do
        before { definition.accept_text = true }
        it { is_expected.to be_truthy }
      end
    end
  end 

  describe '#on_traversed' do
    before { definition.after_callback = callback }
    context 'when set symbol' do
      let(:callback) { :foo }
      it 'calls method on reader' do
        reader_mock = double(Nokogireader::Reader)
        expect(reader_mock).to receive(callback).with(:bar).and_return :baz
        expect(definition.on_traversed(reader_mock, :bar)).to be :baz
      end
    end

    context 'when set Proc' do
      let(:callback) do
        Proc.new { |reader, data| "#{reader} #{data}" }
      end
      it 'calls Proc' do
        expect(definition.on_traversed(:foo, :bar)).to eq 'foo bar'
      end
    end
  end
end
