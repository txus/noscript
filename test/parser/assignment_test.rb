require 'test_helper'

class ParserAssignmentTest < MiniTest::Unit::TestCase

  def test_simple_assignment
    parses "a = 'foo'" do |nodes|
      assignment = nodes.first

      assert_kind_of LocalAssignNode, assignment

      assert_equal "a", assignment.lhs.name
      assert_equal "foo", assignment.rhs.value
    end
  end

  def test_simple_assignment_with_whitespace_identifier
    parses "oh my lord = 'foo'" do |nodes|
      assignment = nodes.first

      assert_kind_of LocalAssignNode, assignment

      assert_equal 'oh my lord', assignment.lhs.name
      assert_equal "foo", assignment.rhs.value
    end
  end

  def test_operation_assignment
    parses 'a = (3 + 3) * 4' do |nodes|
      assignment = nodes.first
      assert_kind_of LocalAssignNode, assignment
      assert_equal "a", assignment.lhs.name

      multiplication = assignment.rhs
      assert_kind_of CallNode, multiplication
      assert_equal '*', multiplication.method
      assert_equal 4, multiplication.arguments.first.value

      parens_op = multiplication.receiver
      assert_kind_of CallNode, parens_op
      assert_equal 3, parens_op.receiver.value
      assert_equal '+', parens_op.method
      assert_equal 3, parens_op.arguments.first.value
    end
  end

  def test_double_assignment
    parses 'a = b = 3' do |nodes|
      assignment = nodes.first
      assert_kind_of LocalAssignNode, assignment
      assert_equal "a", assignment.lhs.name

      other_assignment = assignment.rhs
      assert_kind_of LocalAssignNode, other_assignment

      assert_equal "b", other_assignment.lhs.name
      assert_equal 3, other_assignment.rhs.value
    end
  end

  def test_assignment_with_call
    parses 'a = foo()' do |nodes|
      assignment = nodes.first
      assert_kind_of LocalAssignNode, assignment
      assert_equal "a", assignment.lhs.name

      call = assignment.rhs
      assert_kind_of CallNode, call
      assert_nil call.receiver
      assert_equal "foo", call.method.name
      assert_equal [], call.arguments
    end
  end

  def test_assignment_with_function_definition
    parses 'a = -> b, c; 3; end;' do |nodes|
      assignment = nodes.first
      assert_kind_of LocalAssignNode, assignment
      assert_equal "a", assignment.lhs.name

      function = assignment.rhs
      assert_kind_of FunctionNode, function
      assert_equal ['b', 'c'], function.params.map(&:name).map(&:name)

      body = function.body.nodes
      assert_equal [3], body.map(&:value)
    end
  end

  def test_assignment_with_expression
    parses "a = a - 3" do |nodes|
      assignment = nodes.first
      assert_kind_of LocalAssignNode, assignment
      assert_equal "a", assignment.lhs.name

      exp = assignment.rhs
      assert_kind_of CallNode, exp
      assert_equal "a", exp.receiver.name
      assert_equal "-", exp.method
      assert_equal [3], exp.arguments.map(&:value)
    end
  end

  def test_slot_assignment
    parses "foo.a = 3\n " do |nodes|
      assignment = nodes.first
      assert_kind_of SlotAssignNode, assignment

      assert_equal "foo", assignment.receiver.name
      assert_equal "a", assignment.slot.name
      assert_equal 3, assignment.value.value
    end
  end
end
