module Noscript
  module AST
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
  end
end
