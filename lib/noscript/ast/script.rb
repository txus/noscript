module Noscript
  module AST
    [
      :Node, :StringLiteral, :FixnumLiteral, :ArrayLiteral, :HashLiteral,
      :TrueLiteral, :FalseLiteral, :NilLiteral,
      :LocalVariableAccess,
      :ClosedScope,
    ].
      each { |n| const_set(n, Rubinius::AST.const_get(n)) }
  end
  module Visitable
    def accept(visitor)
      name = self.class.name.split("::").last
      visitor.send "visit_#{name}", self
    end
  end
end

Noscript::AST::Node.send :include, Noscript::Visitable

module Noscript
  module AST
    class Script < Node
      attr_reader :body, :filename

      def initialize(line, filename, body)
        super(line)
        body = Nodes.new(line, body) unless body.is_a?(Nodes)
        @filename = filename
        @body = body
      end
    end

    class Nodes < Node
      attr_reader :expressions

      def initialize(line, expressions)
        super(line)
        @expressions = expressions
      end

      def <<(exp)
        @expressions << exp
      end

      def empty?
        @expressions.empty?
      end
    end

    class FunctionLiteral < Node
      attr_reader :arguments, :body
      def initialize(line, arguments, body)
        super(line)
        @arguments = arguments
        @body = body
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

      def initialize(line, receiver, method, arguments)
        super(line)
        @receiver  = receiver
        @method    = method
        @arguments = arguments
      end
    end

    class Identifier < Node
      attr_reader :name

      def initialize(line, name)
        super(line)
        @name = name
      end
    end

    class LocalVariableAssignment < Node
      attr_reader :name, :value
      def initialize(line, name, value)
        super(line)
        @name = name.is_a?(Identifier) ? name.name : name
        @value = value
      end
    end
#
#
#     class SlotAssignNode < Node
#       attr_reader :receiver, :slot, :value
#       def initialize(receiver, slot, value)
#         @receiver = receiver
#         @slot     = slot
#         @value    = value
#       end
#     end
#
#     class SlotGetNode < Node
#       attr_reader :receiver, :name
#       def initialize(receiver, name)
#         @receiver = receiver
#         @name     = name
#       end
#     end
#
#     class IfNode < Node
#       attr_reader :condition, :body, :else_body
#       def initialize(condition, body, else_body=nil)
#         @condition = condition
#         @body      = body
#         @else_body = else_body
#       end
#     end
#
#     class WhileNode < Node
#       attr_reader :condition, :body
#       def initialize(condition, body)
#         @condition = condition
#         @body      = body
#       end
#     end
  end
end
