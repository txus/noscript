require 'test_helper'

class InteropTest < MiniTest::Unit::TestCase
  module Mixin
    def mixin_method
      1234
    end
  end

  class Foo
    def bar
      34
    end
  end

  def test_call_ruby_from_noscript
    assert_equal Fixnum, compile("Ruby.Fixnum")
  end
end
