module Noscript
  module AST
    class UnaryMinus < Node
      attr_reader :value
      def initialize(value)
        @value = value
      end

      def compile(context)
        -(value.compile(context))
      end
    end
  end
end
