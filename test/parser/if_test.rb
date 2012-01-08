require 'test_helper'

class IfTest < MiniTest::Unit::TestCase

  def test_if
    parses "if foo == 3\n 3\n end" do |nodes|
      if_node = nodes.first

      assert_kind_of IfNode, if_node

      exp = if_node.condition
      assert_kind_of CallNode, exp
      assert_equal "foo", exp.receiver.name
      assert_equal "==", exp.method
      assert_equal 3, exp.arguments.first.value

      assert_equal [3], if_node.body.expressions.map(&:value)
    end
  end

  def test_if_with_else
    parses "if foo != 3\n 3\n else\n 4\n end" do |nodes|
      if_node = nodes.first

      assert_kind_of IfNode, if_node

      exp = if_node.condition
      assert_kind_of CallNode, exp
      assert_equal "foo", exp.receiver.name
      assert_equal "!=", exp.method
      assert_equal 3, exp.arguments.first.value

      assert_equal [3], if_node.body.expressions.map(&:value)
      assert_equal [4], if_node.else_body.expressions.map(&:value)
    end
  end

end
