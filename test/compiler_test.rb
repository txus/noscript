require 'test_helper'
require 'minitest/mock'

module Noscript
  class CompilerTest < MiniTest::Unit::TestCase
    class DummyGenerator
      def initialize
        @code = []
      end

      def compile_all(nodes)
        nodes.each do |node|
          node.compile(self)
        end
      end

      def method_missing(m, *a, &block)
        @code << m
      end

      def assemble
        @code
      end
    end

    def setup
      @compiler = Compiler.new(DummyGenerator)
    end

    def test_compile_integer_literal
      assert_equal [:integer_literal], @compiler.compile("1")
    end

    def test_compile_string_literal
      assert_equal [:string_literal], @compiler.compile("'1'")
    end

    def test_compile_array_literal
      assert_equal [:array_literal], @compiler.compile("[]")
    end

    def test_compile_tuple_literal
      assert_equal [:tuple_literal], @compiler.compile("{}")
    end

    def test_compile_function
      assert_equal [:function_literal], @compiler.compile("-> a; 3; end")
    end

    def test_compile_identifier
      assert_equal [:identifier], @compiler.compile("a")
    end

    def test_compile_true
      assert_equal [:true_literal], @compiler.compile("true")
    end

    def test_compile_false
      assert_equal [:false_literal], @compiler.compile("false")
    end

    def test_compile_nil
      assert_equal [:nil_literal], @compiler.compile("nil")
    end

    def test_compile_call
      assert_equal [:call], @compiler.compile("foo()")
    end

    def test_compile_local_assign
      assert_equal [:set_local], @compiler.compile("a = 3")
    end

    def test_compile_slot_assign
      assert_equal [:assign_slot], @compiler.compile("foo.a = 3")
    end

    def test_compile_slot_get
      assert_equal [:get_slot], @compiler.compile("foo.a")
    end

    def test_compile_if
      assert_equal [:if], @compiler.compile("if true; 1; end")
    end

    def test_compile_while
      assert_equal [:while], @compiler.compile("while true; 1; end")
    end
  end
end
