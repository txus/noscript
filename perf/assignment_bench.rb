require_relative 'nobench'

benchmark(<<CODE)

  a = 34
  b = 91
  c = 'hello'
  d = true
  e = false
  f = nil

CODE
