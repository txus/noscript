require_relative 'nobench'

benchmark(<<CODE)

  bar = 100

  def foo(bar)
    if bar == 0

    else
      foo(bar - 1)
    end
  end

CODE
