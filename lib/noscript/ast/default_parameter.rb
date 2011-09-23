module Noscript
  module AST
    class DefaultParameter < Node
      attr_reader :name, :value

      def initialize(name, value)
        @name = name
        @value = value
      end

      def compile(context)
        value
      end

      def to_s
        name
      end
    end
  end
end
