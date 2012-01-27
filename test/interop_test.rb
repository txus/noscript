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

  def test_toplevel_namespace
    assert_equal Fixnum, compile("Ruby.Fixnum")
  end

  def test_define_ruby_method
    compile(<<-CODE)
      Ruby.Array.def('sum', ->
        @ruby('reduce', '+'.ruby('to_sym'))
      end)
    CODE

    assert_respond_to [], :sum
    assert_equal 6, [1,2,3].sum
  end

  def test_include_ruby_module
    compile(<<-CODE)
      Ruby.InteropTest.Foo.include(Ruby.InteropTest.Mixin)
    CODE

    foo = Foo.new
    assert_respond_to foo, :mixin_method
    assert_equal 1234, foo.mixin_method
  end

  def test_extend_ruby_module
    foo = compile(<<-CODE)
      foo = Ruby.InteropTest.Foo.new()
      foo.extend(Ruby.InteropTest.Mixin)
    CODE

    assert_respond_to foo, :mixin_method
    assert_equal 1234, foo.mixin_method
  end
end
