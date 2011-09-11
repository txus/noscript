module Noscript
  module AST
    class Nodes < Struct.new(:nodes)
      def compile(context)
        nodes.map do |node|
          node.compile(context)
        end.last
      end
    end

    class AssignNode < Struct.new(:lhs, :rhs)
      def compile(context)
        context.store_var(lhs, rhs)
        rhs
      end
    end

    class Identifier < Struct.new(:name)
      def compile(context)
        context.lookup_var(name)
      end
      def to_s
        name
      end
    end

    class DefaultParameter < Struct.new(:name, :value)
      def compile(context)
        value
      end
      def to_s
        name
      end
    end

    class String < Struct.new(:val)
      def compile(context)
        val.to_s
      end
      def to_s
        "'#{val.to_s}'"
      end
    end

    class DefMethod < Struct.new(:name, :params, :body)
      def compile(context)
        context.store_method(name, params, body)
      end
    end

    class MethodCall < Struct.new(:name, :args)
      def compile(context)
        context.lookup_method(name).call(context, *args)
      end
    end

    ## ARITHMETIC

    class Digit < Struct.new(:val)
      def -@
        Digit.new(-to_i)
      end

      def +(num)
        Digit.new num.to_i + to_i
      end

      def -(num)
        Digit.new to_i - num.to_i
      end

      def *(num)
        Digit.new to_i * num.to_i
      end

      def /(num)
        Digit.new to_i / num.to_i
      end

      def compile(context)
        self
      end

      def to_s
        val.to_s
      end

      def to_i
        val.to_i
      end
    end

    class AddNode < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) + rhs.compile(context)
      end
    end

    class SubtractNode < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) - rhs.compile(context)
      end
    end

    class MultiplicationNode < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) * rhs.compile(context)
      end
    end

    class DivisionNode < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) / rhs.compile(context)
      end
    end

    class UnaryMinus < Struct.new(:val)
      def compile(context)
        -(val.compile(context))
      end
    end
  end
end
