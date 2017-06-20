module APL
  module AST
    class Function
      attr_reader :op, :x, :y

      def initialize(op:, x:, y:)
        @op = op
        @x = x
        @y = y
      end

      def compute!
        block = self.class.ops[op] || raise(ArgumentError, "I don't know how to do the #{op} operation.")
        computed_args = [x, y].map do |arg|
          begin
            arg.compute!
          rescue NoMethodError
            arg
          end
        end
        block.call *computed_args
      end

      def eql?(other)
        [:op, :x, :y].all? {|field| self.send(field) == other.send(field) }
      end

      alias_method :==, :eql?

      private

      def self.ops
        @ops ||= {
          '+': ->(x, y) { x + y },
          '-': ->(x, y) { x - y },
          '×': ->(x, y) { x * y },
          '÷': ->(x, y) { x.to_f / y }
        }
      end
    end
  end
end