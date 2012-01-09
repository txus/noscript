require 'test_helper'

module Noscript
  class CompilerTest < MiniTest::Unit::TestCase
    def compile(code)
      Noscript.eval_noscript(code)
    end

    def test_compile_integer_literal
      assert_equal 1, compile("1")
    end

    def test_compile_unary_minus
      assert_equal -1, compile("-1")
    end

    def test_compile_string_literal
      assert_equal '1', compile("'1'")
    end

    def test_compile_assignment
      assert_equal 1, compile("foo = 1; foo")
    end

    def test_compile_array_literal
      assert_equal 1, compile("[1,2].at(0)")
    end

    def test_compile_tuple_literal
      assert_equal({'a' => true, 'b' => false}, compile("{a: true, b: false}"))
    end

    def test_compile_tuple_literal_as_an_expression
      assert_equal(['a', 'b'], compile("{a: true, b: false}.keys()"))
    end

    def test_compile_function_without_arguments
      assert_equal 3, compile("foo = ->; 3; end; foo()")
    end

    def test_compile_function_with_unused_arguments
      assert_equal 3, compile("foo = -> a; 3; end; foo(5)")
    end

    def test_compile_function_with_used_arguments
      assert_equal 10, compile("foo = -> a; a + a; end; foo(5)")
    end

    def test_compile_function_with_multiple_arguments
      assert_equal 7, compile("foo = -> a, b, c; b + c; end; foo(5, 4, 3)")
    end

    # def test_compile_function_as_an_object_slot
    #   assert_equal 4, compile("foo = Object.clone(); foo.bar = ->; 4; end; foo.bar()")
    # end

    def test_compile_true
      assert_equal true, compile("true")
    end

    def test_compile_false
      assert_equal false, compile("false")
    end

    def test_compile_nil
      assert_equal nil, compile("nil")
    end

    def test_compile_call
      assert_equal "1", compile("1.inspect()")
    end

    def test_compile_local_assign
      assert_equal 3, compile("a = 3")
    end

    def test_compile_object_clone
      obj = compile("Object.clone()")
      assert_kind_of Runtime::ObjectType, obj
      assert_equal Runtime::Object, obj.prototype
    end

    def test_compile_object_clone_with_properties
      obj = compile("Object.clone({a: 1})")
      assert_equal 1, obj.get(:a)
    end

    def test_compile_slot_get
      assert_equal 1, compile("obj = Object.clone({a: 1}); obj.a")
    end

    def test_compile_slot_assign
      obj = compile("foo = Object.clone(); foo.a = 3; foo")
      assert_equal 3, obj.get(:a)
    end

    def test_compile_if
      assert_equal 1, compile("if true; 1; end")
    end

    def test_compile_if_else
      assert_equal 2, compile("if false; 1; else; 2; end")
    end

    def test_compile_while
      assert_equal 10, compile("a = 3; while a < 10; a = a + 1; end; a")
    end
  end
end
