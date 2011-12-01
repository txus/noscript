require 'test_helper'

class FunctionCallTest < MiniTest::Unit::TestCase

  def test_slot_get
    parses "a.foo" do |nodes|
      invocation = nodes.first

      assert_kind_of SlotGetNode, invocation
      assert_equal "a", invocation.receiver
      assert_equal "foo", invocation.name
    end
  end

  def test_invocation_without_arguments
    parses "a.foo()" do |nodes|
      invocation = nodes.first

      assert_kind_of CallNode, invocation
      assert_equal "a", invocation.receiver
      assert_equal "foo", invocation.method
      assert_equal [], invocation.arguments
    end
  end

  def test_invocation_with_arguments
    parses "a.foo('hey', 34)" do |nodes|
      invocation = nodes.first

      assert_kind_of CallNode, invocation
      assert_equal "a", invocation.receiver
      assert_equal "foo", invocation.method

      assert_equal ["hey", 34], invocation.arguments.map(&:value)
    end
  end

end
