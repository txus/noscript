require_relative 'nobench'

benchmark(<<CODE)

  if 3 == 3
    true
  else
    false
  end

  if 3 != 3
    false
  else
    true
  end

CODE
