module Noscript
  class Object
    attr_accessor :parent
    attr_accessor :slots
    attr_accessor :traits

    PROTECTED_SLOTS = ['clone', 'uses', 'each']

    def initialize
      @parent = nil
      @slots  = {}
      @traits = []

      add_slot('clone', lambda { |*args|
        child = Object.new
        child.parent = self

        context = args.shift
        tuple = args.shift

        if context && tuple
          tuple.compile(context).each do |k, v|
            child.slots[k] = v
          end
        end

        child
      })

      add_slot('uses', lambda { |context, trait_name|
        trait = trait_name.compile(context)
        use_trait(trait)
      })

      add_slot('each', lambda { |context, fun|
        yieldable = self.slots.delete_if do |k,v|
          Object::PROTECTED_SLOTS.include?(k)
        end

        method = fun.compile(context)

        yieldable.each do |slot|
          method.call(context, AST::String.new(slot.first), slot.last)
        end
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
