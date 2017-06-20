require 'spec_helper'

module APL::AST
  RSpec.describe Function do
    let(:op) { Faker::Lorem.characters(1).to_sym }
    let(:x) { rand 100 }
    let(:y) { rand 100 }

    subject { described_class.new op: op, x: x, y: y }

    describe 'constructor' do
      it 'takes an operator and two arguments' do
        expect(subject).to be_a_kind_of described_class
      end
    end

    describe '#compute!' do
      subject { super().compute! }

      context 'dyadic' do
        context '+' do
          let(:op) { :+ }

          it 'adds the two arguments' do
            expect(subject).to be == x + y
          end

          context 'nested arguments' do
            let(:y1) { rand 100 }
            let(:y2) { rand 100 }
            let(:y) { described_class.new op: :×, x: y1, y: y2 }

            it 'computes the nested functions first, then uses them as arguments' do
              expect(subject).to be == x + (y1 * y2)
            end
          end
        end

        context '-' do
          let(:op) { :- }

          it 'subtracts y from x' do
            expect(subject).to be == x - y
          end
        end

        context '×' do
          let(:op) { :× }

          it 'multiplies the two arguments' do
            expect(subject).to be == x * y
          end
        end

        context '÷' do
          let(:op) { :÷ }

          it 'divides x by y (floating-point)' do
            expect(subject).to be_within(0.001).of x.to_f / y
          end
        end
      end
    end

    context 'equality' do
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
            {op: op.to_s * 2, x: x, y: y},
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
end