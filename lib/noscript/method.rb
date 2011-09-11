module Noscript
  class Method
    attr_reader :params, :body
    def initialize(params, body)
      @params = params
      @body = body
    end

    def call(context, *args)
      ctx = Context.new(context)
      @params.each_with_index do |param, idx|
        if passed_value = args[idx]
          ctx.store_var(param.name, passed_value.compile(ctx))
        elsif param.is_a?(AST::DefaultParameter)
          ctx.store_var(param.name, param.value)
        else
          raise "This method expected #{@params.size} arguments, not #{args.size}"
        end
      end
      @body.compile(ctx)
    end
  end
end
