require 'spec_helper'
require 'parslet/rig/rspec'

module APL
  RSpec.describe Parser do
    it 'is a Parslet parser' do
      expect(subject).to be_a_kind_of Parslet::Parser
    end

    context 'parsing' do
      let(:integer) { rand(1..1000) }
      let(:integer_string) { integer.to_s }
      let(:float) { rand(1..1000000) * 0.01 }
      let(:float_string) { '%.2f' % float }

      describe '#number' do
        subject { super().number }

        it 'parses positive integers' do
          expect(subject).to parse integer_string
        end

        it 'parses negative integers' do
          expect(subject).to parse "¯#{integer_string}"
        end

        it 'parses floats' do
          expect(subject).to parse float_string
          expect(subject).to parse "¯#{float_string}"
        end

        it 'parses exponential notation' do
          expect(subject).to parse "#{float_string}e#{integer}"
          expect(subject).to parse "#{float_string}E¯#{integer}"
        end

        it 'does not parse letters' do
          expect(subject).not_to parse 'a'
        end

        it 'does not parse negative signs except at the beginning' do
          expect(subject).not_to parse "#{integer_string}¯#{integer_string}"
          expect(subject).not_to parse "#{integer_string}¯"
        end

        it 'does not parse numbers with more than one decimal point' do
          expect(subject).not_to parse "#{float_string}.#{integer}"
        end
      end

      describe '#expression' do
        let(:function_symbols) { %w[+ - × ÷] }
        let(:function) { function_symbols.sample }
        let(:numbers) { [integer_string, float_string] }
        let(:simple_dyadic) { [numbers.sample, function, numbers.sample].join }

        subject { super().expression }

        it 'can be a number' do
          expect(subject).to parse integer_string
          expect(subject).to parse float_string
        end

        it 'can be a dyadic function call on two numbers' do
          expect(subject).to parse simple_dyadic
        end

        it 'can have multiple dyadic calls without parentheses' do
          expression = (1..3).map { [numbers.sample, function_symbols.sample] }.join << numbers.sample
          expect(subject).to parse expression
        end

        it 'can parenthesize the first argument' do
          expect(subject).to parse "(#{simple_dyadic})#{function}#{numbers.sample}"
        end

        it 'can parenthesize the second argument' do
          expect(subject).to parse "#{numbers.sample}#{function}(#{simple_dyadic})"
        end

        it 'can be a monadic call, with or without parentheses' do
          monadic = "#{function}#{numbers.sample}"
          expect(subject).to parse monadic
          expect(subject).to parse "(#{monadic})"
        end
      end
    end
  end
end