module Noscript
  module AST
    class IfNode < Node
      attr_reader :expression, :body, :else_body

      def initialize(expression, body, else_body=nil)
        @expression = expression
        @body = body
        @else_body = else_body
      end

      def compile(context)
        result = @expression.compile(context)
        if result
          @body.compile(context)
        elsif else_body
          @else_body.compile(context)
        end
      end
    end
  end
end
