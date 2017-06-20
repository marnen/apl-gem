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
    let(:parser) { subject_class.new input }

    subject { parser }

    it 'is a KPeg parser' do
      expect(subject).to be_a_kind_of KPeg::CompiledParser
    end

    context 'parsing' do
      let(:integer) { rand(1..1000) }
      let(:integer_string) { integer.to_s }
      let(:float) { rand(1..1000000) * 0.01 }
      let(:float_string) { '%.2f' % float }
      let(:result) { subject.result }
      let(:rule) { nil }

      before(:each) { subject.parse rule }

      describe 'number' do
        let(:rule) { 'number' }

        context 'positive integer' do
          let(:input) { integer_string }

          it { is_expected.to be_success }
          it 'returns the integer' do
            expect(result).to be == integer
          end
        end

        context 'negative integers' do
          let(:input) { "¯#{integer_string}" }
          it { is_expected.to be_success }
          it 'returns the integer' do
            expect(result).to be == -integer
          end
        end

        context 'floats' do
          let(:tolerance) { 0.1 }
          let(:input) { float_string }

          context 'without sign' do
            it { is_expected.to be_success }
            it 'returns the float' do
              expect(result).to be_within(tolerance).of float
            end
          end

          context 'with negative sign' do
            let(:input) { '¯' << super() }
            it { is_expected.to be_success }
            it 'returns the float' do
              expect(result).to be_within(tolerance).of -float
            end
          end

          context 'exponential notation' do
            let(:exponent) { rand 2..10 }
            let(:exponent_string) { exponent.to_s }
            let(:input) { float_string + e + exponent_string }
            let(:exponentiated) { float * 10 ** exponent }

            context 'capital E' do
              let(:e) { 'E' }
              it { is_expected.to be_success }
              it 'returns the exponentiated number' do
                expect(result).to be_within(tolerance).of exponentiated
              end

              context 'negative exponent' do
                let(:exponent_string) { "¯#{super()}" }
                let(:exponentiated) { float * 10 ** -exponent }
                it { is_expected.to be_success }
                it 'returns the exponentiated number' do
                  expect(result).to be_within(tolerance).of exponentiated
                end
              end
            end

            context 'lowercase e' do
              let(:e) { 'e' }
              it { is_expected.to be_success }
              it 'returns the exponentiated number' do
                expect(result).to be_within(tolerance).of exponentiated
              end
            end
          end
        end

        context 'non-numeric characters' do
          let(:input) { 'a' }
          it { is_expected.to be_failure }
        end

        context 'negative signs other than at the beginning' do
          context 'middle' do
            let(:input) { "#{integer_string}¯#{integer_string}" }
            it { is_expected.to be_failure }
          end

          context 'end' do
            let(:input) { "#{integer_string}¯" }
            it { is_expected.to be_failure }
          end
        end

        context 'more than one decimal point' do
          let(:input) { "#{float_string}.#{integer}" }
          it { is_expected.to be_failure }
        end

        context 'consuming trailing whitespace' do
          let(:input) { "#{integer_string} " }
          it { is_expected.to be_success }
          it 'returns the number as if the whitespace did not exist' do
            expect(result).to be == integer
          end
        end
      end

      describe 'vector' do
        let(:rule) { 'vector' }

        context 'single integer' do
          let(:input) { integer_string }
          it { is_expected.to be_failure }
        end

        context 'multiple numbers' do
          let(:integers) { Array.new(rand 2..5) { rand 1..1000 } }
          let(:numbers) { integers }
          let(:numbers_string) { numbers.join ' ' }
          let(:input) { numbers_string }

          context 'all positive integers' do
            it { is_expected.to be_success }
            it 'returns the array' do
              expect(result).to be == integers
            end
          end

          context 'negative too' do
            let(:negative) { rand 1..1000 }
            let(:negative_string) { "¯#{negative}" }
            let(:numbers_string) { super() + " #{negative_string}" }
            it { is_expected.to be_success }
            it 'returns the array' do
              expect(result).to be == numbers + [-negative]
            end
          end

          context 'floats' do
            let(:numbers) { super() << (rand(1..1000) * 0.01) }
            it { is_expected.to be_success }
            it 'returns the array' do
              result.each_with_index do |float, index|
                expect(float).to be_within(0.1).of numbers[index]
              end
            end
          end
        end
      end

      describe 'root' do
        let(:function_symbols) { %i[+ - × ÷] }
        let(:function) { function_symbols.sample }
        let(:numbers) { [integer_string, float_string] }
        let(:vector) { [integer, float] }
        let(:vector_string) { vector.join ' ' }
        let(:rule) { 'root' }

        context 'single value' do
          context 'integer' do
            let(:input) { integer_string }
            it { is_expected.to be_success }
          end

          context 'float' do
            let(:input) { float_string }
            it { is_expected.to be_success }
          end

          context 'vector' do
            let(:input) { vector_string }
            it { is_expected.to be_success }
          end
        end

        context 'function calls' do
          let(:x) { numbers.sample }
          let(:y) { numbers.sample }
          let(:dyadic) { [x, function, y].join }

          context 'dyadic' do
            let(:input) { dyadic }

            context 'two simple numbers' do
              it { is_expected.to be_success }

              it 'returns an AST representation of the function' do
                expect(result).to be == APL::AST::Function.new(op: function, x: x.to_f, y: y.to_f)
              end
            end

            context 'vector on left' do
              let(:x) { vector_string }
              it { is_expected.to be_success }

              it 'returns an AST representation of the function' do
                expect(result).to be == APL::AST::Function.new(op: function, x: vector, y: y.to_f)
              end
            end

            context 'vector on right' do
              let(:y) { vector_string }
              it { is_expected.to be_success }

              it 'returns an AST representation of the function' do
                expect(result).to be == APL::AST::Function.new(op: function, x: x.to_f, y: vector)
              end
            end

            context 'multiple dyadic calls without parentheses' do
              let(:tokens) { (1..3).map { [numbers.sample, function_symbols.sample] } + [numbers.sample] }
              let(:input) { tokens.join }

              it { is_expected.to be_success }

              it 'returns a nested AST representation of the function' do
                expect(result).to be == AST::Function.new({
                  x: tokens[0].first.to_f,
                  op: tokens[0].last,
                  y: AST::Function.new({
                    x: tokens[1].first.to_f,
                    op: tokens[1].last,
                    y: AST::Function.new({
                      x: tokens[2].first.to_f,
                      op: tokens[2].last,
                      y: tokens[3].to_f
                    })
                  })
                })

              end
            end

            context 'parentheses' do
              let(:z) { numbers.sample }

              context 'first argument parenthesized' do
                let(:input) { "(#{dyadic})#{function}#{z}" }

                it { is_expected.to be_success }

                it 'returns an AST representation of the function' do
                  expect(result).to be == AST::Function.new({
                    x: AST::Function.new({
                      x: x.to_f, op: function, y: y.to_f
                    }),
                    op: function,
                    y: z.to_f
                  })
                end
              end

              context 'second argument parenthesized' do
                let(:input) { "#{z}#{function}(#{dyadic})" }
                it { is_expected.to be_success }

                it 'returns an AST representation of the function' do
                  expect(result).to be == AST::Function.new({
                    x: z.to_f,
                    op: function,
                    y: AST::Function.new({
                      x: x.to_f, op: function, y: y.to_f
                    })
                  })
                end
              end
            end
          end

          context 'monadic' do
            let(:simple_monadic) {  "#{function}#{y}" }

            context 'simple number' do
              let(:input) { simple_monadic }
              it { is_expected.to be_success }

              it 'returns an AST representation with nil left argument' do
                expect(result).to be == AST::Function.new(x: nil, op: function, y: y.to_f)
              end
            end

            context 'all parenthesized' do
              let(:input) { "(#{simple_monadic})" }
              it { is_expected.to be_success }

              it 'returns an AST representation' do
                expect(result).to be == AST::Function.new(x: nil, op: function, y: y.to_f)
              end
            end

            context 'only argument parenthesized' do
              let(:input) { "#{function}(#{dyadic})" }
              it { is_expected.to be_success }

              it 'returns a nested AST representation' do
                expect(result).to be == AST::Function.new(
                  x: nil, op: function, y: AST::Function.new(
                    x: x.to_f, op: function, y: y.to_f
                  )
                )
              end
            end
          end
        end
      end
    end
  end
end