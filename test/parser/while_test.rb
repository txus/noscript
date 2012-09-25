require 'test_helper'

class WhileTest < MiniTest::Unit::TestCase

  def test_while
    parses "while foo == 3\n 3\n end" do |nodes|
      while_node = nodes.first

      assert_kind_of WhileNode, while_node

      exp = while_node.condition
      assert_kind_of CallNode, exp
      assert_equal :foo, exp.receiver.name
      assert_equal "==", exp.method
      assert_equal 3, exp.arguments.first.value

      assert_equal [3], while_node.body.expressions.map(&:value)
    end
  end

end
