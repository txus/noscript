module Noscript
  module AST
    class Node
      def graph
        Rubinius::AST::AsciiGrapher.new(self, Node).print
      end

      def visit(visitor)
        raise NotImplementedError, "Don't know how to visit #{self.inspect}"
      end
    end
  end
end
