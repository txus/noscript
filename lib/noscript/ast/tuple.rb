module Noscript
  module AST
    class Tuple < Node
      attr_reader :body

      def initialize(body)
        @body = body
      end

      def compile(context)
        Tuple.new(@body.inject({}) do |acc, elem|
          acc.update(elem.first.to_s => elem.last.compile(context))
        end)
      end

      def keys
        @body.keys
      end
    end
  end
end
