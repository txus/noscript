require 'test_helper'

class FunTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_fun_without_args
    parses "->\n 3\n end" do |nodes|
      fun = nodes.first

      assert_kind_of FunNode, fun
      assert_equal [], fun.arguments

      body = fun.body.nodes
      assert_equal [Digit.new(3)], body
    end
  end

  def test_fun_with_one_argument
    parses "-> bar; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunNode, fun
      assert_equal [Identifier.new('bar')], fun.arguments

      body = fun.body.nodes
      assert_equal [Digit.new(3)], body
    end
  end

  def test_fun_with_multiple_arguments
    parses "-> bar, baz; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunNode, fun
      assert_equal [Identifier.new('bar'), Identifier.new('baz')], fun.arguments

      body = fun.body.nodes
      assert_equal [Digit.new(3)], body
    end
  end

  def test_fun_with_default_param
    parses "-> bar, baz='ho'; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunNode, fun
      assert_equal [
        Identifier.new('bar'),
        DefaultParameter.new(
          Identifier.new('baz'),
          String.new('ho')
        )
      ], fun.arguments

      body = fun.body.nodes
      assert_equal [Digit.new(3)], body
    end
  end
end
