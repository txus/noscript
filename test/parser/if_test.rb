require 'test_helper'

class IfTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_if
    parses "if foo == 3\n 3\n end" do |nodes|
      if_node = nodes.first

      assert_kind_of IfNode, if_node

      exp = if_node.expression
      assert_kind_of EqualityExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Digit.new(3), exp.rhs

      assert_equal Nodes.new([Digit.new(3)]), if_node.body
    end
  end

  def test_if_with_else
    parses "if foo != 3\n 3\n else\n 4\n end" do |nodes|
      if_node = nodes.first

      assert_kind_of IfNode, if_node

      exp = if_node.expression
      assert_kind_of InequalityExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Digit.new(3), exp.rhs

      assert_equal Nodes.new([Digit.new(3)]), if_node.body
      assert_equal Nodes.new([Digit.new(4)]), if_node.else_body
    end
  end

end
