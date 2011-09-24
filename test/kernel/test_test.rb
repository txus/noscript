require 'test_helper'

class TestTest < MiniTest::Unit::TestCase

  def test_test
    code = <<-CODE

  MyTestCase = TestCase.clone({

    setup: ->
      @foo = 'bar'
    end,

    it does foo things: ->
      @assert equal(@foo, 'bar')
    end,

    it does bar things: ->
      @assert(true)
    end,

    it can fail too: ->
      @assert(false)
    end,

    teardown: ->
      @foo = nil
    end

  })

  MyTestCase.run()
CODE

    expected = "\e[32m.\e[0m\e[32m.\e[0m\e[31mF\e[0m\n\n\e[0m3 tests, 3 assertions, 1 failures\n    * Expected false to be truthy.\n"
    assert_output expected do
      compiles(code)
    end
  end

end
