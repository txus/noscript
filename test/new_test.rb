require 'test_helper'
require 'minitest/mock'

module Noscript
  class CompilerTest < MiniTest::Unit::TestCase
    def setup
      @compiler = Compiler.new
    end

    def test_compile_integer_literal
      assert_equal 1, @compiler.compile("1").call
    end

    def test_compile_string_literal
      assert_equal '1', @compiler.compile("'1'").call
    end

    def test_compile_assignment
      assert_equal 1, @compiler.compile("foo = 1; foo").call
    end

    def test_compile_array_literal
      assert_equal 1, @compiler.compile("[1,2].at(0)").call
    end

    def test_compile_tuple_literal
      assert_equal({'a' => true, 'b' => false}, @compiler.compile("{a: true, b: false}").call)
    end

    def test_compile_tuple_literal_as_an_expression
      assert_equal(['a', 'b'], @compiler.compile("{a: true, b: false}.keys()").call)
    end

    def test_compile_function_without_arguments
      assert_equal 3, @compiler.compile("foo = ->; 3; end; foo()").call
    end

    def test_compile_function_with_unused_arguments
      assert_equal 3, @compiler.compile("foo = -> a; 3; end; foo(5)").call
    end

    def test_compile_function_with_used_arguments
      assert_equal 10, @compiler.compile("foo = -> a; a + a; end; foo(5)").call
    end

    def test_compile_function_with_multiple_arguments
      assert_equal 7, @compiler.compile("foo = -> a, b, c; b + c; end; foo(5, 4, 3)").call
    end

    def test_compile_true
      assert_equal true, @compiler.compile("true").call
    end

    def test_compile_false
      assert_equal false, @compiler.compile("false").call
    end

    def test_compile_nil
      assert_equal nil, @compiler.compile("nil").call
    end

    def test_compile_call
      assert_equal "1", @compiler.compile("1.inspect()").call
    end

    def test_compile_local_assign
      assert_equal 3, @compiler.compile("a = 3").call
    end

    def test_compile_object_clone
      obj = @compiler.compile("Object.clone()").call
      assert_kind_of Runtime::ObjectType, obj
      assert_equal Runtime::Object, obj.prototype
    end

    def test_compile_object_clone_with_properties
      obj = @compiler.compile("Object.clone({a: 1})").call
      assert_equal 1, obj.get(:a)
    end

    def test_compile_slot_get
      assert_equal 1, @compiler.compile("obj = Object.clone({a: 1}); obj.a").call
    end

    def test_compile_slot_assign
      obj = @compiler.compile("foo = Object.clone(); foo.a = 3; foo").call
      assert_equal 3, obj.get(:a)
    end

    def test_compile_if
      assert_equal 1, @compiler.compile("if true; 1; end").call
    end

    def test_compile_if_else
      assert_equal 2, @compiler.compile("if false; 1; else; 2; end").call
    end

    def test_compile_while
      assert_equal 10, @compiler.compile("a = 3; while a < 10; a = a + 1; end; a").call
    end
  end
end
