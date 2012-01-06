module Noscript
  module AST
    class Literal < Node
      attr_accessor :value

      def initialize(value)
        @value = value
      end

      def visit(visitor)
        visitor.literal self
      end
    end

    class String < Literal
      def initialize(value)
        super value.to_s
      end
    end

    class NilKind < Literal
      def initialize
        super nil
      end

      def visit(visitor)
        visitor.nil_kind self
      end
    end

    class TrueKind < Literal
      def initialize
        super true
      end

      def visit(visitor)
        visitor.true_kind self
      end
    end

    class FalseKind < Literal
      def initialize
        super false
      end

      def visit(visitor)
        visitor.false_kind self
      end
    end
  end
end
