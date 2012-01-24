require_relative 'nobench'

benchmark(<<CODE)

  MyTrait = Trait.build("MyTrait", {
    gimme my name: ->
      @name
    end
  })
  foo = Object.clone()
  foo.name = 'John'
  foo.uses(MyTrait)

  foo.gimme my name()

CODE
