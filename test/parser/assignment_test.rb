require 'test_helper'

class ParserAssignmentTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_simple_assignment
    parses "a = 'foo'" do |nodes|
      assignment = nodes.first

      assert_kind_of Assignment, assignment

      assert_equal Identifier.new('a'), assignment.lhs
      assert_equal String.new('foo'), assignment.rhs
    end
  end

  def test_simple_assignment_with_whitespace_identifier
    parses "oh my lord = 'foo'" do |nodes|
      assignment = nodes.first

      assert_kind_of Assignment, assignment

      assert_equal Identifier.new('oh my lord'), assignment.lhs
      assert_equal String.new('foo'), assignment.rhs
    end
  end

  def test_operation_assignment
    parses 'a = (3 + 3) * 4' do |nodes|
      assignment = nodes.first
      assert_kind_of Assignment, assignment
      assert_equal Identifier.new('a'), assignment.lhs

      multiplication = assignment.rhs
      assert_kind_of MultiplicationNode, multiplication

      assert_equal Integer.new(4), multiplication.rhs

      parens_op = multiplication.lhs
      assert_kind_of AddNode, parens_op
      assert_equal Integer.new(3), parens_op.lhs
      assert_equal Integer.new(3), parens_op.rhs
    end
  end

  def test_double_assignment
    parses 'a = b = 3' do |nodes|
      assignment = nodes.first
      assert_kind_of Assignment, assignment
      assert_equal Identifier.new('a'), assignment.lhs

      other_assignment = assignment.rhs
      assert_kind_of Assignment, other_assignment

      assert_equal Identifier.new('b'), other_assignment.lhs
      assert_equal Integer.new(3), other_assignment.rhs
    end
  end

  def test_assignment_with_message
    parses 'a = foo()' do |nodes|
      assignment = nodes.first
      assert_kind_of Assignment, assignment
      assert_equal Identifier.new('a'), assignment.lhs

      message = assignment.rhs
      assert_kind_of Message, message
      assert_equal Message.new(nil, FunctionCall.new(Identifier.new('foo'), [])), message
    end
  end

  def test_assignment_with_function_definition
    parses 'a = -> b, c; 3; end;' do |nodes|
      assignment = nodes.first
      assert_kind_of Assignment, assignment
      assert_equal Identifier.new('a'), assignment.lhs

      function = assignment.rhs
      assert_kind_of Function, function
      assert_equal [Identifier.new('b'), Identifier.new('c')], function.params

      body = function.body.nodes
      assert_equal [Integer.new(3)], body
    end
  end

  def test_assignment_with_semicolon
    parses "a = 3;" do |nodes|
      assignment = nodes.first
      assert_kind_of Assignment, assignment

      assert_equal Identifier.new('a'), assignment.lhs
      assert_equal Integer.new(3), assignment.rhs
    end
  end

  def test_assignment_with_newline
    parses "a = 3\n " do |nodes|
      assignment = nodes.first
      assert_kind_of Assignment, assignment

      assert_equal Identifier.new('a'), assignment.lhs
      assert_equal Integer.new(3), assignment.rhs
    end
  end

  def test_assignment_with_expression
    parses "a = a - 3\n " do |nodes|
      assignment = nodes.first
      assert_kind_of Assignment, assignment

      assert_equal Identifier.new('a'), assignment.lhs
      assert_equal SubtractNode.new(
        Identifier.new('a'),
        Integer.new(3)
      ), assignment.rhs
    end
  end

  def test_slot_assignment
    parses "foo.a = 3\n " do |nodes|
      assignment = nodes.first
      assert_kind_of Assignment, assignment

      assert_equal Identifier.new('foo'), assignment.receiver
      assert_equal Identifier.new('a'), assignment.lhs
      assert_equal Integer.new(3), assignment.rhs
    end
  end
end
