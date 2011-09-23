module Noscript
  module AST
    class WhileNode < Node
      attr_reader :expression, :body

      def initialize(expression, body)
        @expression = expression
        @body = body
      end

      def compile(context)
        while expression.compile(context)
          body.compile(context)
        end
      end
    end
  end
end
