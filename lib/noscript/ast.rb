module Noscript
  module AST

    class Node
      attr_reader :filename, :line

      def pos(filename, line)
        @filename = filename
        @line = line
      end

      def ==(other)
        instance_variables.all? do |ivar|
          instance_variable_get(ivar) == other.instance_variable_get(ivar)
        end
      end
    end

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
        "[#{@nodes.map(&:to_s).join(', ')}]"
      end
    end

    class Assignment < Node
      attr_reader :receiver, :lhs, :rhs

      def initialize(receiver, lhs, rhs)
        @receiver = receiver
        @lhs = lhs
        @rhs = rhs
      end

      def compile(context)
        val = rhs.compile(context)
        if @receiver
          # rcv.a = 3 sets a slot on rcv to 3
          rcv = @receiver.compile(context)
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

    class Identifier < Node
      attr_reader :name, :deref

      def initialize(name, deref=false)
        @name = name
        @deref = deref
      end

      def compile(context)
        if deref
          context.current_receiver.send(name)
        else
          context.lookup_var(name)
        end
      end

      def to_s
        name
      end
    end

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

    class String < Node
      attr_reader :value, :interpolated

      INTERPOLATION_REGEX = /\#{([^}]*)\}/

      def initialize(value, interpolated=false)
        @value = value
        @interpolated = !!@value.scan(INTERPOLATION_REGEX)
      end

      def compile(context)
        if @interpolated
          parser = Noscript::Parser.new
          interpolated_string = value.gsub(/\#{([^}]*)\}/) do
            parser.scan_str($1).compile(context).to_s
          end

          String.new(interpolated_string)
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
          value =~ /^#{str.value}/
        }
      end

      def to_s
        eval("\"#{value}\"")
      end
    end

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
    end

    class Array < Node
      attr_reader :body

      def initialize(body)
        @body = body
      end

      def compile(context)
        Array.new(@body.map do |element|
          element.compile(context)
        end)
      end

      def send(message)
        __send__ message.name
      end

      define_method('push') do
        lambda {|context, *args|
          element = args.first
          @body.push(element.compile(context))
        }
      end

      define_method('each') do
        lambda { |context, fun|
          method = fun.compile(context)

          @body.each do |element|
            method.call(context, element)
          end
        }
      end
    end

    class Function < Node
      attr_reader :params, :body

      def initialize(params, body)
        @params = params
        @body = body
      end

      def call(context, *args)
        raise_argument_error(args) if args.size > params.size

        ctx = Context.new(context)
        ctx.current_receiver = context.current_receiver

        params.each_with_index do |param, idx|
          if !(passed_value = args[idx]).nil?

            # Try to get the value from the context, or from the current receiver
            if !passed_value.compile(ctx).nil?
              compiled_value = passed_value.compile(ctx)
            else
              compiled_value = ctx.current_receiver.send(passed_value)
            end

            ctx.store_var(param.name, compiled_value)
          elsif param.is_a?(AST::DefaultParameter)
            ctx.store_var(param.name, param.value)
          else
            raise_argument_error(args)
          end
        end
        body.compile(ctx)
      end

      def compile(context)
        self
      end

      private

      def raise_argument_error(args)
        raise "This function expected #{params.size} arguments, not #{args.size}"
      end
    end

    class FunctionCall < Node
      attr_reader :name, :arguments

      def initialize(name, arguments)
        @name = name
        @arguments = arguments
      end

      def compile(context)
        self
      end
    end

    class Message < Node
      attr_reader :receiver, :slot

      def initialize(receiver, slot)
        @receiver = receiver
        @slot = slot
      end

      def compile(context)
        ctx = Context.new(context)
        ctx.current_receiver = context.current_receiver

        if @receiver
          # rcv.foo() looks up the message in the receiver slots
          rcv = @receiver.compile(context)

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
        slot.is_a?(FunctionCall)
      end
    end

    class IfNode < Node
      attr_reader :expression, :body, :else_body

      def initialize(expression, body, else_body=nil)
        @expression = expression
        @body = body
        @else_body = else_body
      end

      def compile(context)
        result = @expression.compile(context)
        if result
          @body.compile(context)
        elsif else_body
          @else_body.compile(context)
        end
      end
    end

    class WhileNode < Node
      attr_reader :expression, :body

      def initialize(expression, body)
        @expression = expression
        @body = body
      end

      def compile(context)
        while expression.compile(context)
          body.compile(context)
        end
      end
    end

    ## ARITHMETIC

    class Integer < Node
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def -@
        Integer.new(-to_i)
      end

      def +(num)
        Integer.new num.to_i + to_i
      end

      def -(num)
        Integer.new to_i - num.to_i
      end

      def *(num)
        Integer.new to_i * num.to_i
      end

      def /(num)
        Integer.new to_i / num.to_i
      end

      def compile(context)
        self
      end

      def to_s
        @value.to_s
      end

      def to_i
        @value.to_i
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

    class BinaryOperation < Node
      attr_reader :lhs, :rhs

      def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs
      end
    end

    class UnaryMinus < Node
      attr_reader :value
      def initialize(value)
        @value = value
      end

      def compile(context)
        -(value.compile(context))
      end
    end

    class AddNode < BinaryOperation
      def compile(context)
        lhs.compile(context) + rhs.compile(context)
      end
    end

    class SubtractNode < BinaryOperation
      def compile(context)
        lhs.compile(context) - rhs.compile(context)
      end
    end

    class MultiplicationNode < BinaryOperation
      def compile(context)
        lhs.compile(context) * rhs.compile(context)
      end
    end

    class DivisionNode < BinaryOperation
      def compile(context)
        lhs.compile(context) / rhs.compile(context)
      end
    end

    # Boolean expressions

    class EqualityExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) == rhs.compile(context)
      end
    end

    class InequalityExpression < BinaryOperation
      def compile(context)
        !(lhs.compile(context) == rhs.compile(context))
      end
    end

    class GtExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) > rhs.compile(context)
      end
    end

    class GteExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) >= rhs.compile(context)
      end
    end

    class LtExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) < rhs.compile(context)
      end
    end

    class LteExpression < BinaryOperation
      def compile(context)
        lhs.compile(context) <= rhs.compile(context)
      end
    end

    class Exception < StandardError
    end

  end
end

class TrueClass; def compile(context); self; end; end;
class FalseClass; def compile(context); self; end; end;
class NilClass; def compile(context); self; end; end;
