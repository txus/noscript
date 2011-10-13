require 'test_helper'

class MessageTest < MiniTest::Unit::TestCase

  def setup
    @context = Context.new
    @object = Object.new
    @function = Function.new(
      # PARAMS
      [Identifier.new('bar')],

      # BODY
      Nodes.new([
        Integer.new(74)
      ])
    )
    @object.add_slot('bar', @function)
    @object.add_slot('baz', Integer.new(99))
    @context.store_var('foo', @object)
  end

  def test_message_call_without_parens_returns_the_function
    # foo.bar
    @message = Message.new(
      Identifier.new('foo'),
      Identifier.new('bar')
    )

    retval = @message.compile(@context)

    assert_equal @function, retval
  end

  def test_message_call_with_empty_parens_calls_the_function
    # foo.bar(9)
    @message = Message.new(
      Identifier.new('foo'),
      FunctionCall.new(
        Identifier.new('bar'),
        [Integer.new(9)]
      )
    )

    retval = @message.compile(@context)

    assert_equal Integer.new(74), retval
  end
end
