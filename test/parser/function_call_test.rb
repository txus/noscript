require 'test_helper'

class FunctionCallTest < MiniTest::Unit::TestCase

  def test_slot_get
    parses "a.foo" do |nodes|
      invocation = nodes.first

      assert_kind_of SlotGet, invocation
      assert_equal "a", invocation.receiver.name
      assert_equal :foo, invocation.name.name.to_sym
    end
  end

  def test_invocation_without_arguments
    parses "a.foo()" do |nodes|
      invocation = nodes.first

      assert_kind_of CallNode, invocation
      assert_equal "a", invocation.receiver.name
      assert_equal "foo", invocation.method.name
      assert_equal [], invocation.arguments
    end
  end

  def test_invocation_with_arguments
    parses "a.foo('hey', 34)" do |nodes|
      invocation = nodes.first

      assert_kind_of CallNode, invocation
      assert_equal "a", invocation.receiver.name
      assert_equal "foo", invocation.method.name

      assert_equal "hey", invocation.arguments.first.string
      assert_equal 34, invocation.arguments.last.value
    end
  end

  def test_operations
    parses "a + b" do |nodes|
      invocation = nodes.first

      assert_kind_of CallNode, invocation
      assert_equal "a", invocation.receiver.name
      assert_equal "+", invocation.method
      assert_equal "b", invocation.arguments.first.name
    end
  end

end
