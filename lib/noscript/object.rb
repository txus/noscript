module Noscript
  class Object
    attr_accessor :parent
    attr_accessor :slots

    def initialize
      @parent = nil
      @slots  = {}
    end

    def clone
      child = Object.new
      child.parent = self
      child
    end

    def send(message, *arguments, &block)
      @slots[message.to_s] or (@parent.slots[message.to_s] if @parent) or raise "Inexistent slot #{message} in #{self}"
    end

    def add_slot(name, value)
      @slots[name] = value
    end
  end
end
