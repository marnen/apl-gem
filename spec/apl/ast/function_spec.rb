require 'spec_helper'

module APL::AST
  RSpec.describe Function do
    let(:op) { Faker::Lorem.characters(1) }
    let(:x) { rand 100 }
    let(:y) { rand 100 }

    subject { described_class.new op: op, x: x, y: y }

    describe 'constructor' do
      it 'takes an operator and two arguments' do
        expect(subject).to be_a_kind_of described_class
      end
    end

    shared_examples_for 'an equality method' do
      it 'returns true when both objects are the same' do
        expect(subject.send method, subject).to be true
      end

      it 'returns true when parameters are the same' do
        expect(subject.send method, described_class.new(op: op, x: x, y: y)).to be true
      end

      it 'does not return true when the parameters are different' do
        [
          {op: op, x: y, y: x},
          {op: op * 2, x: x, y: y},
          {op: op, x: x + 1, y: y},
          {op: op, x: x, y: y + 1}
        ].each do |params|
          expect(subject.send method, described_class.new(params)).not_to be true
        end
      end
    end

    describe '==' do
      it_behaves_like 'an equality method' do
        let(:method) { :== }
      end
    end

    describe 'eql?' do
      it_behaves_like 'an equality method' do
        let(:method) { :eql? }
      end
    end
  end
end