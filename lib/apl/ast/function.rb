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
        ops = monadic? ? self.class.monadic : self.class.dyadic
        block = ops[op] || raise(ArgumentError, "I don't know how to do the #{op} operation.")
        computed_args = args.map do |arg|
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

      def self.monadic
        @monadic ||= {
          '+': ->(y) { y },
          '-': ->(y) { -y },
          '×': ->(y) do
            if y == 0
              0
            elsif y < 0
              -1
            else
              1
            end
          end,
          '÷': ->(y) { 1.0 / y }
        }
      end

      def self.dyadic
        @dyadic ||= {
          '+': ->(x, y) { x + y },
          '-': ->(x, y) { x - y },
          '×': ->(x, y) { x * y },
          '÷': ->(x, y) { x.to_f / y }
        }
      end

      def args
        [x, y].compact
      end

      def monadic?
        x.nil?
      end
    end
  end
end