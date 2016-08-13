require 'spec_helper'

describe Nokogireader::ReadData do
  let(:definition) { Nokogireader::Definition.new }
  let(:node_mock) do
    node_mock = double(::Nokogiri::XML::Reader)
    allow(node_mock).to receive(:attribute).with('foo').and_return 'bar'
    allow(node_mock).to receive(:name).and_return 'test'
    node_mock
  end

  describe '#initialize' do
    before { definition.read_attributes = [:foo] }
    subject { described_class.new(:baz, definition, node_mock) }

    its(:parent) { should be :baz }
    its(:attributes) { should eq({ foo: 'bar' }) }
  end

  describe '#add_child' do
    let(:data) { described_class.new(nil, definition, node_mock) }
    let(:child) { Nokogireader::Definition.new }

    it 'returns new child data' do
      expect(described_class)
        .to receive(:new).with(data, child, node_mock).and_call_original
      expect(data.add_child(child, node_mock)).to be_a(described_class)
    end

    context 'when multiple is truthy' do
      before do
        child.multiple = true
        @new_child = data.add_child(child, node_mock)
      end

      subject { data.children['test'] }
      it { is_expected.to eq [@new_child] }
    end

    context 'when multiple is falsy' do
      before do
        child.multiple = false
        @new_child = data.add_child(child, node_mock)
      end

      subject { data.children['test'] }
      it { is_expected.to eq @new_child }
    end
  end

  describe '#clear_child_for' do
    let(:data) { described_class.new(nil, definition, node_mock) }
    before do
      data.add_child(
        Nokogireader::Definition.new.tap { |d| d.multiple = multiple },
        node_mock
      )
      data.clear_child_for(node_mock)
    end

    subject { data.children['test'] }

    context 'when multiple is falsy' do
      let(:multiple) { false }
      it { is_expected.to be_nil }
    end

    context 'when multiple is truthy' do
      let(:multiple) { true }
      it { is_expected.to eq [] }
    end
  end

  describe '#method_missing' do
    let(:data) { described_class.new(nil, definition, node_mock) }
    before { data.children['test'] = :foo }

    context 'when no key in children' do
      it 'raises NoMethodError' do
        expect { data.bar }.to raise_error(NoMethodError)
      end
    end

    context 'when exists key in children' do
      it 'returns data' do
        expect(data.test).to be :foo
      end
    end
  end
end
