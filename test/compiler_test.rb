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
      @compiler.compile("1").must_equal [:integer_literal]
    end

    def test_compile_string_literal
      @compiler.compile("'1'").must_equal [:string_literal]
    end

    def test_compile_array_literal
      @compiler.compile("[]").must_equal [:array_literal]
    end

    def test_compile_tuple_literal
      @compiler.compile("{}").must_equal [:tuple_literal]
    end

    def test_compile_function
      @compiler.compile("-> a; 3; end").must_equal [:function_literal]
    end

    def test_compile_true
      @compiler.compile("true").must_equal [:true_literal]
    end

    def test_compile_false
      @compiler.compile("false").must_equal [:false_literal]
    end

    def test_compile_nil
      @compiler.compile("nil").must_equal [:nil_literal]
    end

    def test_compile_call
      @compiler.compile("foo()").must_equal [:call]
    end

    def test_compile_local_assign
      @compiler.compile("a = 3").must_equal [:set_local]
    end

    def test_compile_slot_assign
      @compiler.compile("foo.a = 3").must_equal [:assign_slot]
    end

    def test_compile_slot_get
      @compiler.compile("foo.a").must_equal [:get_slot]
    end

    def test_compile_if
      @compiler.compile("if true; 1; end").must_equal [:if]
    end

    def test_compile_while
      @compiler.compile("while true; 1; end").must_equal [:while]
    end
  end
end
