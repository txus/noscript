module Noscript
  module AST
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

          if rcv.is_a?(Node) || rcv.is_a?(Object)
            retval = rcv.send(name)
          else # Native Ruby object
            retval = lambda {|context, *args|
              args.map! {|a| a.compile(context) }
              block = proc { }
              if args.last.is_a?(Function)
                block = args.pop.to_proc(context)
              end
              rcv.send(name.to_s, *args, &block)
            }
          end

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
  end
end
