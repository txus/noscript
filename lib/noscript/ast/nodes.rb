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

    class Node
      attr_reader :filename, :line

      def pos(filename, line)
        @filename = filename
        @line = line
      end
    end

    class LiteralNode < Node
      attr_reader :value

      def initialize(value)
        @value = value
      end
    end

    class IntegerNode < LiteralNode; end
    class StringNode < LiteralNode; end

    class TrueNode < LiteralNode
      def initialize
        super(true)
      end
    end
    class FalseNode < LiteralNode
      def initialize
        super(false)
      end
    end
    class NilNode < LiteralNode
      def initialize
        super(nil)
      end
    end

    # Node of a method call or local variable access, can take any of these forms:
    #
    #   method # this form can also be a local variable
    #   method(argument1, argument2)
    #   receiver.method
    #   receiver.method(argument1, argument2)
    #
    class CallNode < Node
      attr_reader :receiver, :method, :arguments

      def initialize(receiver, method, arguments)
        @receiver  = receiver
        @method    = method
        @arguments = arguments
      end
    end

    # Setting the value of a local variable or a slot.
    class AssignNode < Node
      attr_reader :lhs, :rhs, :receiver
      def initialize(lhs, rhs, receiver=nil)
        @lhs, @rhs = lhs, rhs
        @receiver  = receiver
      end
    end

    class IfNode < Node
      attr_reader :condition, :body, :else_body
      def initialize(condition, body, else_body=nil)
        @condition = condition
        @body      = body
        @else_body = else_body
      end
    end

    class WhileNode < Node
      attr_reader :condition, :body
      def initialize(condition, body)
        @condition = condition
        @body      = body
      end
    end
  end
end
