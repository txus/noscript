require 'set'

module Noscript
  class TraitList
    include Enumerable

    def initialize(owner)
      @owner = owner
      @traits = {}
    end

    def include?(object)
      @traits.values.include?(object)
    end

    def each(&block)
      @traits.values.each(&block)
    end

    def push(trait, trait_name)
      check_conflicts_with(trait, trait_name)
      @traits.update(trait_name => trait)
    end

    def check_conflicts_with(trait, trait_name)
      conflicts = {}
      @traits.each do |name, t|
        conflicting_slots =
          (t.slots.keys.flatten & trait.slots.keys.flatten) - @owner.slots.keys
        if conflicting_slots.length > 0
          conflicts[name] ||= []
          conflicts[name] += conflicting_slots
        end
      end

      printable = conflicts.to_a.map do |t_name, slots|
        slots.map do |s|
          "#{t_name}##{s}"
        end.join(', ')
      end.join(', ')

      unless conflicts.empty?
        raise Exception, "Cannot use trait #{trait_name}. Conflicting functions: #{printable}\nThe host object should explicitly resolve those conflicts by implementing those functions before using the trait."
      end
    end

    def lookup(message)
      lookup_explicit_message(message) || lookup_implicit_message(message)
    end

    def lookup_explicit_message(message)
      name, *msg = message.split(' ')
      if trait = @traits[name]
        trait.get(msg.join(' '))
      else
        return nil
      end
    end

    def lookup_implicit_message(message)
      trait = @traits.values.find do |trait|
        trait.implements?(message)
      end
      trait.get(message) if trait
    end
  end
end
