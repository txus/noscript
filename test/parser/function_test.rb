require 'test_helper'

class FunctionLiteralTest < MiniTest::Unit::TestCase

  def test_fun_without_args
    parses "->\n 3\n end" do |nodes|
      fun = nodes.first

      assert_kind_of FunctionLiteral, fun
      assert_equal [], fun.arguments

      body = fun.body.expressions
      assert_equal [3], body.map(&:value)
    end
  end

  def test_fun_with_one_param
    parses "-> bar; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunctionLiteral, fun
      assert_equal ["bar"], fun.arguments

      body = fun.body.expressions
      assert_equal [3], body.map(&:value)
    end
  end

  def test_fun_with_multiple_arguments
    parses "-> bar, baz; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunctionLiteral, fun
      assert_equal ["bar", "baz"], fun.arguments

      body = fun.body.expressions
      assert_equal [3], body.map(&:value)
    end
  end

  def test_fun_with_empty_body
    parses "-> bar, baz; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunctionLiteral, fun
      assert_equal ["bar", "baz"], fun.arguments

      body = fun.body.expressions.first
      assert_kind_of NilLiteral, body
    end
  end
end
