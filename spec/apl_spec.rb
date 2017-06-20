require "spec_helper"

RSpec.describe APL do
  it "has a version number" do
    expect(APL::VERSION).not_to be nil
  end

  describe '#run' do
    it 'calls the APL parser on the input and computes the result' do
      program = Faker::Lorem.sentence
      parser = double 'APL::Parser'
      result = double 'APL::AST'
      answer = double 'The answer!'
      expect(parser).to receive(:parse).ordered
      expect(parser).to receive(:result).ordered.and_return result
      expect(result).to receive(:compute!).and_return answer
      expect(APL::Parser).to receive(:new).with(program).and_return parser

      expect(APL.run program).to be == answer
    end

    it 'executes APL code' do
      expect(APL.run '8÷1+1').to be == 4
    end
  end
end
