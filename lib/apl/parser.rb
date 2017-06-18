require 'parslet'

module APL
  class Parser < Parslet::Parser
    rule(:expression) { function_call | number | parenthesize(expression) }

    rule(:function_call) { term >> function >> expression }
    rule(:function) { match['+-×÷'] }

    rule(:term) { parenthesize(expression) | number }

    rule(:number) { simple_number >> exponent.maybe }
    rule(:simple_number) { float | integer }
    rule(:integer) { negative_sign.maybe >> digits }
    rule(:float) { integer >> decimal }
    rule(:decimal) { radix >> digits }
    rule(:exponent) { match['Ee'] >> integer }
    rule(:digits) {  match['\\d'].repeat }
    rule(:radix) { str '.' }
    rule(:negative_sign) { str '¯' }

    private

    def parenthesize(rule)
      str('(') >> rule >> str(')')
    end
  end
end