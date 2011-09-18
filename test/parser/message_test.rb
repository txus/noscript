require 'test_helper'

class MessageTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_message
    parses "a.foo" do |nodes|
      message = nodes.first

      assert_kind_of Message, message
      assert_equal Identifier.new('a'), message.receiver
      assert_equal Identifier.new('foo'), message.slot
      refute message.call?
    end
  end

  def test_message_without_arguments
    parses "a.foo()" do |nodes|
      message = nodes.first

      assert_kind_of Message, message
      assert_equal Identifier.new('a'), message.receiver
      assert_equal FunCall.new(Identifier.new('foo'), []), message.slot
      assert message.call?
    end
  end

  def test_message_with_arguments
    parses "a.foo('hey', 34)" do |nodes|
      message = nodes.first

      assert_kind_of Message, message
      assert_equal Identifier.new('a'), message.receiver
      assert_equal FunCall.new(
        Identifier.new('foo'),
        [
          String.new('hey'),
          Digit.new(34)
        ]
      ), message.slot
      assert message.call?
    end
  end

end
