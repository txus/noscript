module Noscript
  class Context
    def self.generate
      ctx = new

      # Define native ruby methods
      ctx.store_var('print', lambda { |context, *args|
        puts *(args.map! {|a| a.compile(context).to_s })
      })

      ctx.store_var('trait', lambda { |context, *args|
        Trait.new(args.first.compile(context))
      })

      ctx.store_var('raise', lambda { |context, *args|
        raise(RuntimeError, args.first.compile(context).to_s)
      })

      ctx.store_var('Object', Object.new)

      ctx
    end

    attr_accessor :lvars, :current_receiver

    def initialize(parent_context = nil)
      @parent = parent_context
      @lvars = {}
    end

    def lookup_var(symbol)
      result = @lvars[symbol.to_s] ||
        (@parent.lookup_var(symbol.to_s) if @parent)
      return result || raise("Undefined local variable: #{symbol}")
    end

    def store_var(symbol, value)
      @lvars[symbol.to_s] = value
    end
  end
end
