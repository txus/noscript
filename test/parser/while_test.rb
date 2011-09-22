require 'test_helper'

class WhileTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_while
    parses "while foo == 3\n 3\n end" do |nodes|
      while_node = nodes.first

      assert_kind_of WhileNode, while_node

      exp = while_node.expression
      assert_kind_of EqualityExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Integer.new(3), exp.rhs

      assert_equal [Integer.new(3)], while_node.body.nodes
    end
  end

end
