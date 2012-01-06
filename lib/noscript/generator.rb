module Noscript
  class Generator < Rubinius::Generator
    def noscript_send(name, args = 0)
      send "noscript:#{name}".to_sym, args
    end
  end
end
