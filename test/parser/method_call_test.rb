require 'test_helper'

class MessageTest < MiniTest::Unit::TestCase

  def test_call_message_without_args
    parses "foo()" do |nodes|
      message = nodes.first

      assert_kind_of Message, message
      refute message.receiver
      assert_equal Identifier.new('foo'), message.name
      assert_equal [], message.arguments
    end
  end

  def test_call_message_with_args
    parses "foo('hey', 34)" do |nodes|
      message = nodes.first

      assert_kind_of Message, message
      refute message.receiver
      assert_equal Identifier.new('foo'), message.name
      assert_equal [String.new('hey'), Integer.new(34)], message.arguments
    end
  end

  def test_call_message_with_arithmetic
    parses "foo(3 * 2, 9)" do |nodes|
      message = nodes.first

      assert_kind_of Message, message
      refute message.receiver

      assert_equal Identifier.new('foo'), message.name
      assert_equal [
        MultiplicationNode.new(
          Integer.new(3),
          Integer.new(2)
        ),
        Integer.new(9)
      ], message.arguments
    end
  end

  def test_call_message_with_receiver
    parses "bar.foo('hey')" do |nodes|
      message = nodes.first

      assert_kind_of Message, message
      assert_equal Identifier.new('bar'), message.receiver
      assert_equal Identifier.new('foo'), message.name
      assert_equal [String.new('hey')], message.arguments
    end
  end

end
