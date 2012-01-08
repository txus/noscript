require 'test_helper'

class ParserAssignmentTest < MiniTest::Unit::TestCase

  def test_simple_assignment
    parses "a = 'foo'" do |nodes|
      assignment = nodes.first

      assert_kind_of LocalVariableAssignment, assignment

      assert_equal "a", assignment.name
      assert_equal "foo", assignment.value.string
    end
  end

  def test_simple_assignment_with_whitespace_identifier
    parses "oh my lord = 'foo'" do |nodes|
      assignment = nodes.first

      assert_kind_of LocalVariableAssignment, assignment

      assert_equal 'oh my lord', assignment.name
      assert_equal "foo", assignment.value.string
    end
  end

  def test_operation_assignment
    parses 'a = (3 + 3) * 4' do |nodes|
      assignment = nodes.first
      assert_kind_of LocalVariableAssignment, assignment
      assert_equal "a", assignment.name

      multiplication = assignment.value
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
      assert_kind_of LocalVariableAssignment, assignment
      assert_equal "a", assignment.name

      other_assignment = assignment.value
      assert_kind_of LocalVariableAssignment, other_assignment

      assert_equal "b", other_assignment.name
      assert_equal 3, other_assignment.value.value
    end
  end

  def test_assignment_with_call
    parses 'a = foo()' do |nodes|
      assignment = nodes.first
      assert_kind_of LocalVariableAssignment, assignment
      assert_equal "a", assignment.name

      call = assignment.value
      assert_kind_of CallNode, call
      assert_nil call.receiver
      assert_equal "foo", call.method.name
      assert_equal [], call.arguments
    end
  end

  def test_assignment_with_function_definition
    parses 'a = -> b, c; 3; end;' do |nodes|
      assignment = nodes.first
      assert_kind_of LocalVariableAssignment, assignment
      assert_equal "a", assignment.name

      function = assignment.value
      assert_kind_of FunctionLiteral, function
      assert_equal ['b', 'c'], function.arguments

      body = function.body
      assert_equal [3], body.expressions.map(&:value)
    end
  end

  def test_assignment_with_expression
    parses "a = a - 3" do |nodes|
      assignment = nodes.first
      assert_kind_of LocalVariableAssignment, assignment
      assert_equal "a", assignment.name

      exp = assignment.value
      assert_kind_of CallNode, exp
      assert_equal "a", exp.receiver.name
      assert_equal "-", exp.method
      assert_equal [3], exp.arguments.map(&:value)
    end
  end

  def test_slot_assignment
    parses "foo.a = 3\n " do |nodes|
      assignment = nodes.first
      assert_kind_of SlotAssign, assignment

      assert_equal "foo", assignment.receiver.name
      assert_equal :a, assignment.name
      assert_equal 3, assignment.value.value
    end
  end
end
