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

    attr_accessor :lvars, :methods

    def initialize(parent_context = nil)
      @parent = parent_context
      @lvars = {}
      @methods = {}
    end

    def lookup_var(symbol)
      result = @lvars[symbol.to_s] ||
        (@parent.lookup_var(symbol.to_s) if @parent)
      return result || raise("Undefined local variable: #{symbol}")
    end

    def store_var(symbol, value)
      @lvars[symbol.to_s] = value
    end

    def store_ruby_method(symbol, &body)
      raise "Body must be a ruby proc" unless body.is_a?(Proc)
      @methods[symbol.to_s] = body
    end
  end
end
