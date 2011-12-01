require 'test_helper'

class FunctionNodeTest < MiniTest::Unit::TestCase

  def test_fun_without_args
    parses "->\n 3\n end" do |nodes|
      fun = nodes.first

      assert_kind_of FunctionNode, fun
      assert_equal [], fun.params

      body = fun.body.nodes
      assert_equal [3], body.map(&:value)
    end
  end

  def test_fun_with_one_param
    parses "-> bar; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunctionNode, fun
      assert_equal ["bar"], fun.params.map(&:name)

      body = fun.body.nodes
      assert_equal [3], body.map(&:value)
    end
  end

  def test_fun_with_multiple_params
    parses "-> bar, baz; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunctionNode, fun
      assert_equal ["bar", "baz"], fun.params.map(&:name)

      body = fun.body.nodes
      assert_equal [3], body.map(&:value)
    end
  end

  def test_fun_with_default_param
    parses "-> bar, baz='ho'; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of FunctionNode, fun
      params = fun.params
      assert_equal "bar", params[0].name
      assert_equal "baz", params[1].name
      assert_equal "ho", params[1].default_value.value

      body = fun.body.nodes
      assert_equal [3], body.map(&:value)
    end
  end
end
