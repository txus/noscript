module Noscript
  class Generator < Rubinius::Generator
    def noscript_send(name, args = 0)
      send "noscript:#{name}".to_sym, args
    end

    def size
      @current_block.instance_eval { @stack }
    end

    def print
      return_stack
      push_const :Rexpl
      find_const :Output
      swap_stack
      send :print_stack, 1, true
      pop
    end
  end
end
