require 'test_helper'

class FunCallTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_call_method_without_args
    parses "foo()" do |nodes|
      fun_call = nodes.first

      assert_kind_of FunCall, fun_call
      assert_equal 'foo', fun_call.name
      assert_equal [], fun_call.args
    end
  end

  def test_call_method_with_args
    parses "foo('hey', 34)" do |nodes|
      fun_call = nodes.first

      assert_kind_of FunCall, fun_call
      assert_equal 'foo', fun_call.name
      assert_equal [String.new('hey'), Digit.new(34)], fun_call.args
    end
  end

  def test_call_method_with_other_fun_calls
    parses "foo('hey', bar())" do |nodes|
      fun_call = nodes.first

      assert_kind_of FunCall, fun_call
      assert_equal 'foo', fun_call.name
      assert_equal [String.new('hey'), FunCall.new('bar', [])], fun_call.args
    end
  end

  def test_call_method_with_arithmetic
    parses "foo(3 * 2, 9)" do |nodes|
      fun_call = nodes.first

      assert_kind_of FunCall, fun_call
      assert_equal [
        MultiplicationNode.new(
          Digit.new(3),
          Digit.new(2)
        ),
        Digit.new(9)
      ], fun_call.args
    end
  end

end
