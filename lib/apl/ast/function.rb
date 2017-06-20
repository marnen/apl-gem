module APL
  module AST
    class Function
      attr_reader :op, :x, :y

      def initialize(op:, x:, y:)
        @op = op
        @x = x
        @y = y
      end

      def eql?(other)
        [:op, :x, :y].all? {|field| self.send(field) == other.send(field) }
      end

      alias_method :==, :eql?
    end
  end
end