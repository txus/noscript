module Noscript
  class Context
    attr_reader :parent
    def self.generate
      ctx = new

      # Define native ruby methods
      ctx.store_var('puts', lambda { |context, *args|
        puts *(args.map! {|a| a.compile(context).to_s })
      })

      ctx.store_var('print', lambda { |context, *args|
        print *(args.map! {|a| a.compile(context).to_s }).join(' ')
      })

      ctx.store_var('trait', lambda { |context, *args|
        Trait.new(args.first.compile(context))
      })

      ctx.store_var('raise', lambda { |context, *args|
        raise(AST::Exception, args.first.compile(context).to_s)
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
      return @lvars[symbol.to_s] if !@lvars[symbol.to_s].nil?
      return @parent.lookup_var(symbol.to_s) if @parent && !@parent.lookup_var(symbol.to_s).nil?

      raise("Undefined local variable: #{symbol}")
    end

    def store_var(symbol, value)
      @lvars[symbol.to_s] = value
    end
  end
end
