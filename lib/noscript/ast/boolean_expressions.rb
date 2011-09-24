module Noscript
  module AST
    class EqualityExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) == rhs.compile(context)
      end
    end

    class InequalityExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) != rhs.compile(context)
      end
    end

    class GtExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) > rhs.compile(context)
      end
    end

    class GteExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) >= rhs.compile(context)
      end
    end

    class LtExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) < rhs.compile(context)
      end
    end

    class LteExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) <= rhs.compile(context)
      end
    end
  end
end
