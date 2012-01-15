module Noscript
  class Generator < Rubinius::Generator
    def noscript_send(name, args = 0)
      send "noscript:#{name}".to_sym, args
    end

    def push_runtime
      push_const :Runtime
    end

    def raise_if_nil(exception_class, message)
      ok = new_label
      done = new_label

      dup
      git ok # goto the end if it's not nil

      # Else, raise
      push_rubinius
      push_const :"#{exception_class}"
      push_literal message
      send :raise, 2, true
      pop

      ok.set!
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
