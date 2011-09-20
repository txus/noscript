module Noscript
  module AST
    class Nodes < Struct.new(:nodes)
      def push(element)
        nodes << element
      end

      def compile(context)
        nodes.map do |node|
          node.compile(context)
        end.last
      end
    end

    class AssignNode < Struct.new(:receiver, :lhs, :rhs)
      def compile(context)
        val = rhs.compile(context)
        if receiver
          # rcv.a = 3 sets a slot on rcv to 3
          rcv = receiver.compile(context)
          rcv.add_slot(lhs.name, val)
        elsif context.current_receiver && lhs.deref
          # @foo = 'bar' sets a slot on the current receiver.foo to 'bar'
          context.current_receiver.add_slot(lhs.name, val)
        else
          # a = 3 stores a local var
          context.store_var(lhs, val)
        end
        val
      end
    end

    class Identifier < Struct.new(:name, :deref)
      def compile(context)
        if deref
          context.current_receiver.slots[name]
        else
          context.lookup_var(name)
        end
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
      INTERPOLATION_REGEX = /\#{([^}]*)\}/

      def compile(context)
        if val.scan(INTERPOLATION_REGEX)
          parser = Noscript::Parser.new
          interpolated = val.gsub(/\#{([^}]*)\}/) do
            parser.scan_str($1).compile(context).to_s
          end

          String.new(interpolated)
        else
          self
        end
      end

      def send(message)
        __send__ message.name
      end

      # Native methods must return an object that responds to #call.
      # TOOD: Refactor this into something nicer.
      define_method('starts with') do
        lambda {|context, *args|
          str = args.first
          val =~ /^#{str.val}/
        }
      end

      def ==(other)
        val == other.val
      end

      def to_s
        "#{val.to_s}"
      end
    end

    class Tuple < Struct.new(:body)
      def compile(context)
        body.inject({}) do |a,e|
          a.update(e.first.to_s => e.last.compile(context))
        end
      end
    end

    class FunNode < Struct.new(:arguments, :body)
      def compile(context)
        Method.new(arguments, body)
      end
    end

    class FunCall < Struct.new(:name, :arguments)
      def compile(context)
        self
      end
    end

    class Message < Struct.new(:receiver, :slot)
      def compile(context)
        ctx = Context.new(context)
        ctx.current_receiver = context.current_receiver

        if receiver
          # rcv.foo() looks up the message in the receiver slots
          rcv = receiver.compile(context)

          # Save a reference to the current receiver
          ctx.current_receiver = rcv

          retval = rcv.send(name)
        elsif ctx.current_receiver && name.deref
          retval = ctx.current_receiver.send(name)
        else
          # foo() looks up a function in the global context
          retval = context.lookup_var(name)
        end

        if call?
          retval.call(ctx, *arguments)
        else
          retval
        end
      end

      def name
        slot.name
      end

      def arguments
        if slot.respond_to?(:arguments)
          slot.arguments
        else
          []
        end
      end

      def call?
        slot.is_a?(FunCall)
      end
    end

    class Exception < StandardError
    end

    class IfNode < Struct.new(:expression, :body, :else_body)
      def compile(context)
        result = expression.compile(context)
        if result
          body.compile(context)
        elsif else_body
          else_body.compile(context)
        end
      end
    end

    class WhileNode < Struct.new(:expression, :body)
      def compile(context)
        while expression.compile(context)
          body.compile(context)
        end
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

      # Boolean comparisons

      def <(num)
        to_i < num.to_i
      end

      def >(num)
        to_i > num.to_i
      end

      def >=(num)
        to_i >= num.to_i
      end

      def <=(num)
        to_i <= num.to_i
      end

      def ==(num)
        to_i == num.to_i
      end

      def !=(num)
        to_i != num.to_i
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

    # Boolean expressions

    class EqualityExpression < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) == rhs.compile(context)
      end
    end

    class InequalityExpression < Struct.new(:lhs, :rhs)
      def compile(context)
        !(lhs.compile(context) == rhs.compile(context))
      end
    end

    class GtExpression < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) > rhs.compile(context)
      end
    end

    class GteExpression < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) >= rhs.compile(context)
      end
    end

    class LtExpression < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) < rhs.compile(context)
      end
    end

    class LteExpression < Struct.new(:lhs, :rhs)
      def compile(context)
        lhs.compile(context) <= rhs.compile(context)
      end
    end

  end
end

class TrueClass; def compile(context); self; end; end;
class FalseClass; def compile(context); self; end; end;
class NilClass; def compile(context); self; end; end;
