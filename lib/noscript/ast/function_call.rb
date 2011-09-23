module Noscript
  module AST
    class FunctionCall < Node
      attr_reader :name, :arguments

      def initialize(name, arguments)
        @name = name
        @arguments = arguments
      end

      def compile(context)
        self
      end
    end
  end
end
