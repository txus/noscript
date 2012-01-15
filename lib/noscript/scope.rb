module Noscript
  class Scope
    attr_reader :variables, :generator
    alias g generator

    def initialize(generator, parent=nil)
      @parent    = parent
      @variables = []
      @generator = generator
    end

    def slot_for(name)
      if existing = @variables.index(name)
        existing
      else
        @variables << name
        @variables.size - 1
      end
    end

    def push_variable(name, current_depth = 0, g = self.g)
      if existing = @variables.index(name)
        if current_depth.zero?
          g.push_local existing
        else
          g.push_local_depth current_depth, existing
        end
      else
        @parent.push_variable(name, current_depth + 1, g)
      end
    end

    def set_variable(name, current_depth = 0, g = self.g)
      if existing = @variables.index(name)
        if current_depth.zero?
          g.set_local existing
        else
          g.set_local_depth current_depth, existing
        end
      else
        @parent.set_variable(name, current_depth + 1, g)
      end
    end

    def set_local(name)
      g.set_local slot_for(name)
    end

    def set_const(name)
      g.push_runtime
      g.swap
      g.push_literal name
      g.swap
      g.send :const_set, 2
    end
  end
end
