require 'test_helper'

module Noscript
  class TestCaseTest < MiniTest::Unit::TestCase
    def test_test_case
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

      it works with assert equal: ->
        @assert equal(3, 3)
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

      expected = "\e[32m.\e[0m\e[32m.\e[0m\e[32m.\e[0m\e[31mF\e[0m\n\n\e[0m4 tests, 4 assertions, 1 failures\n    * Expected false to be truthy.\n"
      assert_output expected do
        compile(code)
      end
    end
  end
end
