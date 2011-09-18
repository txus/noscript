require_relative 'nobench'

benchmark(<<CODE)

  foo = Object.clone()
  foo.name = 'John'

  bar = foo.clone()
  bar.name
  bar.name = 'Jimmy'
  bar.name

CODE
