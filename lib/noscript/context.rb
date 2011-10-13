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
        raise(Exception, args.first.compile(context).to_s)
      })

      ctx.store_var('Object', Object.new)
      ctx.store_var('Ruby', create_ruby_object)

      ctx
    end

    def self.create_ruby_object
      ruby = Object.new
      ruby.add_slot('eval', lambda { |context, string|
        str = string.compile(context).to_s

        sandbox = ::Object.new
        sandbox.extend(AST)
        sandbox.instance_eval(str)
      })

      # Expose native ruby data structures
      ruby.add_slot('Array', lambda { |context|
        Array.new
      })

      ruby
    end

    attr_accessor :lvars, :current_receiver

    def initialize(parent_context = nil)
      @parent = parent_context
      @lvars = {}
    end

    def lookup_var(symbol)
      return @lvars[symbol.to_s] if @lvars[symbol.to_s]
      return @parent.lookup_var(symbol.to_s) if @parent && @parent.lookup_var(symbol.to_s)

      raise(Exception, "Undefined local variable: #{symbol}")
    end

    def store_var(symbol, value)
      @lvars[symbol.to_s] = value
    end
  end
end
