require 'test_helper'

class AssignmentTest < MiniTest::Unit::TestCase

  def setup
    @context = Context.new
  end

  def test_literal_assignment
    @node = Assignment.new(
      nil,
      Identifier.new('a'),
      Integer.new(3)
    )

    @node.compile(@context)

    assert_equal Integer.new(3), @context.lookup_var('a')
  end

  def test_expression_assignment
    @context.store_var(:a, Integer.new(5))

    @node = Assignment.new(
      nil,
      Identifier.new('a'),
      SubtractNode.new(
        Identifier.new('a'),
        Integer.new('3'),
      )
    )

    @node.compile(@context)

    assert_equal Integer.new(2), @context.lookup_var('a')
  end

  def test_slot_assignment
    @object = Object.new
    @context.store_var('foo', @object)

    @node = Assignment.new(
      Identifier.new('foo'),
      Identifier.new('a'),
      Integer.new('3'),
    )

    @node.compile(@context)

    assert_equal Integer.new(3), @object.slots['a']
  end
end
