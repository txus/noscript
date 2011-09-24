module Noscript
  module AST
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

      def to_proc(context)
        proc { |*args| self.call(context, *args) }
      end

      private

      def raise_argument_error(args)
        raise ArgumentError.new("This function expected #{params.size} arguments, not #{args.size} [#{filename}:#{line}]")
      end
    end
  end
end
