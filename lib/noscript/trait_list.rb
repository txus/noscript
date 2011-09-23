module Noscript
  class TraitList
    include Enumerable

    def initialize
      @traits = []
    end

    def push(trait, trait_name)
      check_conflicts_with(trait, trait_name)
      @traits << trait unless @traits.include?(trait)
    end

    def include?(object)
      @traits.include?(object)
    end

    def each(&block)
      @traits.each(&block)
    end

    def check_conflicts_with(trait, trait_name)
      my_slots = @traits.map(&:slots).map(&:keys).flatten
      other_slots = trait.slots.keys

      conflicts = my_slots & other_slots
      unless conflicts.empty?
        raise Exception, "Cannot use trait #{trait_name}. Conflicting functions: #{conflicts.join(', ')}"
      end
    end
  end
end
