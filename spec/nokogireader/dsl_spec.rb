require 'spec_helper'

describe Nokogireader::DSL do
  let(:definition) { Nokogireader::Definition.new }
  let(:dsl) { described_class.new(definition) }

  describe '#initialize' do
    it 'sets first parameter to @definition' do
      expect(dsl.instance_variable_get(:@definition)).to eq definition
    end
  end

  shared_examples 'a definer child' do |definer|
    subject do
      if defined?(dsl_block)
        dsl.send(definer, :foo, attr: [:bar], &dsl_block)
      else
        dsl.send(definer, :foo, attr: [:bar])
      end
    end

    it { is_expected.to be definition.children['foo'] }

    it 'sets attributes that are read to new definition' do
      expect(subject.read_attributes).to eq [:bar]
    end

    context 'when passed block' do
      let(:dsl_block) { Proc.new { element :baz } }
      it 'calls block for new definition' do
        expect(subject.children['baz']).to be_a Nokogireader::Definition
      end

      it 'set @accept_text to falsy on new definition' do
        expect(subject.accept_text).to be_falsy
      end
    end

    context "when not passed block" do
      it 'set @accept_text to truthy on new definition' do
        expect(subject.accept_text).to be_truthy
      end
    end
  end

  describe '#element' do
    it_behaves_like 'a definer child', :element
  end

  describe '#elements' do
    it_behaves_like 'a definer child', :elements do
      it 'set @multiple to truthy on new definition' do
        expect(subject.multiple).to be_truthy
      end
    end
  end

  describe '#after' do
    subject { definition.after_callback }
    context 'when passed Symbol :foo' do
      before { dsl.after :foo }
      it { is_expected.to be :foo }
    end

    context 'when passed block' do
      let(:callback) { Proc.new { 1 + 1 } }
      before { dsl.after(&callback) }
      it { is_expected.to be callback }
    end
  end

  describe '#dont_store_data' do
    it 'changes flag to truthy' do
      expect { dsl.dont_store_data }
        .to change { definition.dont_store_data }.from(false).to(true)
    end
  end

  describe '#create_child' do
    subject do
      dsl.send(:create_child, { attr: [:foo] }, true)
    end

    it { is_expected.to be_a Nokogireader::Definition }
    its(:accept_text) { should be_truthy }
    its(:read_attributes) { should eq [:foo] }
  end
end
