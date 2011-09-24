module Noscript
  module AST
    class Nodes < Node
      attr_reader :nodes

      def initialize(nodes)
        @nodes = nodes
      end

      def <<(element)
        @nodes << element
      end

      def compile(context)
        @nodes.map do |node|
          node.compile(context)
        end.last
      end

      def to_s
        @nodes.map(&:inspect).join(', ')
      end
    end
  end
end
