module Noscript
  class Trait
    attr_reader :slots

    def initialize(tuple)
      @slots = tuple
    end

    def implements?(message)
      @slots.body.key?(message)
    end
  end
end
