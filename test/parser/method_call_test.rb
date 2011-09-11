require 'test_helper'

class MethodCallTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_call_method_without_args
    parses "foo()" do |nodes|
      method_call = nodes.first

      assert_kind_of MethodCall, method_call
      assert_equal 'foo', method_call.name
      assert_equal [], method_call.args
    end
  end

  def test_call_method_with_args
    parses "foo('hey', 34)" do |nodes|
      method_call = nodes.first

      assert_kind_of MethodCall, method_call
      assert_equal 'foo', method_call.name
      assert_equal [String.new('hey'), Digit.new(34)], method_call.args
    end
  end

  def test_call_method_with_other_method_calls
    parses "foo('hey', bar())" do |nodes|
      method_call = nodes.first

      assert_kind_of MethodCall, method_call
      assert_equal 'foo', method_call.name
      assert_equal [String.new('hey'), MethodCall.new('bar', [])], method_call.args
    end
  end

  def test_call_method_with_arithmetic
    parses "foo(3 * 2, 9)" do |nodes|
      method_call = nodes.first

      assert_kind_of MethodCall, method_call
      assert_equal [
        MultiplicationNode.new(
          Digit.new(3),
          Digit.new(2)
        ),
        Digit.new(9)
      ], method_call.args
    end
  end

end
