module Noscript
  class Method < Struct.new(:params, :body)
    def call(context, *args)
      raise_argument_error(args) if args.size > params.size

      ctx = Context.new(context)
      ctx.current_receiver = context.current_receiver

      params.each_with_index do |param, idx|
        if passed_value = args[idx]
          ctx.store_var(param.name, passed_value.compile(ctx))
        elsif param.is_a?(AST::DefaultParameter)
          ctx.store_var(param.name, param.value)
        else
          raise_argument_error(args)
        end
      end
      body.compile(ctx)
    end

    private

    def raise_argument_error(args)
      raise "This function expected #{params.size} arguments, not #{args.size}"
    end
  end
end
