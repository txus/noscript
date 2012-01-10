module Noscript
  class Generator < Rubinius::Generator
    def noscript_send(name, args = 0)
      p "BEFORE #{size}"
      send "noscript:#{name}".to_sym, args
      p "AFTER #{size}"
    end

    def size
      @current_block.instance_eval { @stack }
    end
  end
end
