require 'spec_helper'
require 'tempfile'

module APL
  RSpec.describe 'Parser' do
    tempfile = Tempfile.new ['parser', '.rb']

    before(:all) do
      parser_path = File.join(File.dirname(__FILE__), '../../lib/apl/parser.kpeg')
      system 'bundle', 'exec', 'kpeg', '-o', tempfile.path, '--force', parser_path
      require tempfile.path
    end

    after(:all) do
      tempfile.unlink
    end

    let(:subject_class) { APL::Parser }
    let(:input) { '' }

    subject { subject_class.new input }

    it 'is a KPeg parser' do
      expect(subject).to be_a_kind_of KPeg::CompiledParser
    end

    context 'parsing' do
      let(:integer) { rand(1..1000) }
      let(:integer_string) { integer.to_s }
      let(:float) { rand(1..1000000) * 0.01 }
      let(:float_string) { '%.2f' % float }
      let(:rule) { nil }

      before(:each) { subject.parse rule }

      describe 'numbers' do
        let(:rule) { 'number' }

        context 'positive integer' do
          let(:input) { integer_string }
          it { is_expected.to be_success }
        end

        context 'negative integers' do
          let(:input) { "¯#{integer_string}" }
          it { is_expected.to be_success }
        end

        context 'floats' do
          let(:input) { float_string }

          context 'without sign' do
            it { is_expected.to be_success }
          end

          context 'with negative sign' do
            let(:input) { '¯' << super() }
            it { is_expected.to be_success }
          end
        end

        context 'exponential notation' do
          let(:input) { float_string + e + integer_string }

          context 'capital E' do
            let(:e) { 'E' }
            it { is_expected.to be_success }
          end

          context 'lowercase e' do
            let(:e) { 'e' }
            it { is_expected.to be_success }
          end
        end

        xit 'does not parse letters' do
          expect(subject).not_to parse 'a'
        end

        xit 'does not parse negative signs except at the beginning' do
          expect(subject).not_to parse "#{integer_string}¯#{integer_string}"
          expect(subject).not_to parse "#{integer_string}¯"
        end

        xit 'does not parse numbers with more than one decimal point' do
          expect(subject).not_to parse "#{float_string}.#{integer}"
        end
      end

      describe 'expression' do
        let(:function_symbols) { %w[+ - × ÷] }
        let(:function) { function_symbols.sample }
        let(:numbers) { [integer_string, float_string] }
        let(:rule) { 'expression' }

        context 'single number' do
          context 'integer' do
            let(:input) { integer_string }
            it { is_expected.to be_success }
          end

          context 'float' do
            let(:input) { float_string }
            it { is_expected.to be_success }
          end
        end

        context 'function calls' do
          let(:simple_dyadic) { [numbers.sample, function, numbers.sample].join }

          context 'dyadic' do
            context 'two simple numbers' do
              let(:input) { simple_dyadic }
              it { is_expected.to be_success }
            end

            context 'multiple dyadic calls without parentheses' do
              let(:input) { (1..3).map { [numbers.sample, function_symbols.sample] }.join << numbers.sample }
              it { is_expected.to be_success }
            end

            context 'first argument parenthesized' do
              let(:input) { "(#{simple_dyadic})#{function}#{numbers.sample}" }
              it { is_expected.to be_success }
            end

            context 'second argument parenthesized' do
              let(:input) { "#{numbers.sample}#{function}(#{simple_dyadic})" }
              it { is_expected.to be_success }
            end
          end

          context 'monadic' do
            let(:simple_monadic) {  "#{function}#{numbers.sample}" }

            context 'simple number' do
              let(:input) { simple_monadic }
              it { is_expected.to be_success }
            end

            context 'all parenthesized' do
              let(:input) { "(#{simple_monadic})" }
              it { is_expected.to be_success }
            end

            context 'only argument parenthesized' do
              let(:input) { "#{function}(#{simple_dyadic})" }
              it { is_expected.to be_success }
            end
          end
        end
      end
    end
  end
end