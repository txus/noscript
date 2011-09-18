module Noscript
  class Object
    attr_accessor :parent
    attr_accessor :slots
    attr_accessor :traits

    def initialize
      @parent = nil
      @slots  = {}
      @traits = []

      add_slot('clone', lambda { |*|
        child = Object.new
        child.parent = self
        child
      })

      add_slot('uses', lambda { |context, trait_name|
        trait = trait_name.compile(context)
        use_trait(trait)
      })
    end

    def send(message, *arguments, &block)
      @slots[message.to_s] or
        lookup_traits(message.to_s) or
        lookup_parent(message.to_s) or
        raise "Inexistent slot #{message} in #{self}"
    end

    def add_slot(name, value)
      @slots[name] = value
    end

    def use_trait(trait)
      @traits << trait unless @traits.include?(trait)
    end

    private

    def lookup_parent(message)
      @parent.slots[message] if @parent
    end

    def lookup_traits(message)
      trait = @traits.find do |trait|
        trait.implements?(message)
      end
      trait.slots[message] if trait
    end
  end
end
