require_relative 'compiler/javascript_generator'

module Noscript
  class Compiler
    def initialize(generator_class)
      @parser = Parser.new
      @generator_class = generator_class
    end

    def compile(code)
      generator = @generator_class.new
      @parser.parse(code).compile(generator)
      generator.assemble
    end
  end

  module AST
    class Nodes
      def compile(generator)
        generator.compile_all(nodes)
      end
    end

    class IntegerNode
      def compile(generator)
        generator.integer_literal(value)
      end
    end

    class StringNode
      def compile(generator)
        generator.string_literal(value)
      end
    end

    class ArrayNode
      def compile(generator)
        generator.array_literal(value)
      end
    end

    class TupleNode
      def compile(generator)
        generator.tuple_literal(value)
      end
    end

    class IdentifierNode
      def compile(generator)
        generator.identifier(value)
      end
    end

    class FunctionNode
      def compile(generator)
        generator.function_literal(params, body)
      end
    end

    class TrueNode
      def compile(generator)
        generator.true_literal
      end
    end

    class FalseNode
      def compile(generator)
        generator.false_literal
      end
    end

    class NilNode
      def compile(generator)
        generator.nil_literal
      end
    end

    class CallNode
      def compile(generator)
        generator.call(receiver, method, arguments)
      end
    end

    class LocalAssignNode
      def compile(generator)
        generator.set_local(lhs, rhs)
      end
    end

    class SlotAssignNode
      def compile(generator)
        generator.assign_slot(receiver, slot, value)
      end
    end

    class SlotGetNode
      def compile(generator)
        generator.get_slot(receiver, name)
      end
    end

    class IfNode
      def compile(generator)
        generator.if condition, body, else_body
      end
    end

    class WhileNode
      def compile(generator)
        generator.while condition, body
      end
    end
  end
end

