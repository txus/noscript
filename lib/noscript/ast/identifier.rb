module Noscript
  module AST
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
  end
end
