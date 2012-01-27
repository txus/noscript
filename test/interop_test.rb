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

  def test_assign_toplevel_namespace
    compile("Ruby.Answer = 42")
    assert_equal 42, ::Answer
  end

  def test_define_ruby_method
    compile(<<-CODE)
      Ruby.Array.def('sum', ->
        @ruby('reduce', '+')
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

  def test_create_ruby_module
    mod = compile(<<-CODE)
      Ruby.Module.create(->
        @def('answer', ->
          42
        end)
      end)
    CODE

    foo = Foo.new
    foo.extend(mod)

    assert_respond_to foo, :answer
    assert_equal 42, foo.answer
  end

  def test_create_ruby_class
    kls = compile(<<-CODE)
      Ruby.Class.create(->
        @def('answer', ->
          42
        end)
      end)
    CODE

    foo = kls.new

    assert_respond_to foo, :answer
    assert_equal 42, foo.answer
  end

  def test_create_ruby_class_inheriting
    kls = compile(<<-CODE)
      Ruby.Class.create(Ruby.Array, ->
        @def('answer', ->
          42
        end)
      end)
    CODE

    foo = kls.new

    assert_respond_to foo, :answer
    assert_kind_of Array, foo
    assert_equal 42, foo.answer
  end

  def test_call_noscript_from_ruby
    john = compile(<<-CODE)
      Object.clone({
        name: 'John',
        age: ->
          20
        end,
        money: -> day of month
          30 - day of month
        end
      })
    CODE

    assert_equal "John", john.name
    assert_equal 20, john.age
    assert_equal 10, john.money(20)
  end
end
