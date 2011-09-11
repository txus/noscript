module Noscript
  class Context
    def self.generate
      ctx = new

      # Define native ruby methods
      ctx.store_ruby_method('print') do |context, *args|
        puts *(args.map! {|a| a.compile(context).to_s })
      end

      ctx
    end

    attr_accessor :lvars, :functions

    def initialize(parent_context = nil)
      @parent = parent_context
      @lvars = {}
      @functions = {}
    end

    def lookup_var(symbol)
      result = @lvars[symbol.to_s] ||
        (@parent.lookup_var(symbol.to_s) if @parent)
      return result || raise("Undefined local variable: #{symbol}")
    end

    def store_var(symbol, value)
      @lvars[symbol.to_s] = value
    end

    def lookup_method(symbol)
      result = @functions[symbol.to_s] ||
        (@parent.lookup_method(symbol.to_s) if @parent)
      return result || raise("Undefined procedure: #{symbol}")
    end

    def store_method(symbol, params, body)
      @functions[symbol.to_s] = Method.new(params, body)
    end

    def store_ruby_method(symbol, &body)
      raise "Body must be a ruby proc" unless body.is_a?(Proc)
      @functions[symbol.to_s] = body
    end
  end
end
