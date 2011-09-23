module Noscript
  module AST
    class BinaryOperation < Node
      attr_reader :lhs, :rhs

      def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs
      end
    end

    class AddNode < BinaryOperation
      def compile(context)
        lhs.compile(context) + rhs.compile(context)
      end
    end

    class SubtractNode < BinaryOperation
      def compile(context)
        lhs.compile(context) - rhs.compile(context)
      end
    end

    class MultiplicationNode < BinaryOperation
      def compile(context)
        lhs.compile(context) * rhs.compile(context)
      end
    end

    class DivisionNode < BinaryOperation
      def compile(context)
        lhs.compile(context) / rhs.compile(context)
      end
    end
  end
end
