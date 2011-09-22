require 'test_helper'

class MessageTest < MiniTest::Unit::TestCase

  def setup
    @context = Noscript::Context.new
    @object = Noscript::Object.new
    @function = Noscript::AST::Function.new(
      # PARAMS
      [Noscript::AST::Identifier.new('bar')],

      # BODY
      Noscript::AST::Nodes.new([
        Noscript::AST::Digit.new(74)
      ])
    )
    @object.add_slot('bar', @function)
    @object.add_slot('baz', Digit.new(99))
    @context.store_var('foo', @object)
  end

  def test_message_call_without_parens_returns_the_function
    # foo.bar
    @message = Noscript::AST::Message.new(
      Noscript::AST::Identifier.new('foo'),
      Noscript::AST::Identifier.new('bar')
    )

    retval = @message.compile(@context)

    assert_equal @function, retval
  end

  def test_message_call_with_empty_parens_calls_the_function
    # foo.bar(9)
    @message = Noscript::AST::Message.new(
      Noscript::AST::Identifier.new('foo'),
      Noscript::AST::FunCall.new(
        Identifier.new('bar'),
        [Digit.new(9)]
      )
    )

    retval = @message.compile(@context)

    assert_equal Digit.new(74), retval
  end
end
