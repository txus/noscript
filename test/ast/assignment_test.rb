require 'test_helper'

class AssignmentTest < MiniTest::Unit::TestCase

  def setup
    @context = Noscript::Context.new
  end

  def test_literal_assignment
    @node = Noscript::AST::AssignNode.new(
      nil,
      Noscript::AST::Identifier.new('a'),
      Noscript::AST::Digit.new(3)
    )

    @node.compile(@context)

    assert_equal Noscript::AST::Digit.new(3), @context.lookup_var('a')
  end

  def test_expression_assignment
    @context.store_var(:a, Noscript::AST::Digit.new(5))

    @node = Noscript::AST::AssignNode.new(
      nil,
      Noscript::AST::Identifier.new('a'),
      Noscript::AST::SubtractNode.new(
        Noscript::AST::Identifier.new('a'),
        Noscript::AST::Digit.new('3'),
      )
    )

    @node.compile(@context)

    assert_equal Noscript::AST::Digit.new(2), @context.lookup_var('a')
  end

  def test_slot_assignment
    @object = Noscript::Object.new
    @context.store_var('foo', @object)

    @node = Noscript::AST::AssignNode.new(
      Noscript::AST::Identifier.new('foo'),
      Noscript::AST::Identifier.new('a'),
      Noscript::AST::Digit.new('3'),
    )

    @node.compile(@context)

    assert_equal Noscript::AST::Digit.new(3), @object.slots['a']
  end
end
