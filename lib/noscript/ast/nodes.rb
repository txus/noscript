module Noscript
  module AST
    class Nodes
      attr_reader :nodes

      def initialize(nodes)
        @nodes = nodes
      end

      def <<(element)
        @nodes << element
      end
#
#       def to_s
#         @nodes.map(&:inspect).join(', ')
#       end
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
    class ArrayNode < LiteralNode; end
    class TupleNode < LiteralNode; end
    class IdentifierNode < LiteralNode
      def name; value; end
    end

    class FunctionNode < Node
      attr_reader :params, :body
      def initialize(params, body)
        @params = params
        @body   = body
      end
    end

    class ParameterNode < Node
      attr_reader :name, :default_value
      def initialize(name, default_value=nil)
        @name          = name
        @default_value = default_value
      end
    end

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
    class LocalAssignNode < Node
      attr_reader :lhs, :rhs
      def initialize(lhs, rhs)
        @lhs, @rhs = lhs, rhs
      end
    end

    class SlotAssignNode < Node
      attr_reader :receiver, :slot, :value
      def initialize(receiver, slot, value)
        @receiver = receiver
        @slot     = slot
        @value    = value
      end
    end

    class SlotGetNode < Node
      attr_reader :receiver, :name
      def initialize(receiver, name)
        @receiver = receiver
        @name     = name
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
