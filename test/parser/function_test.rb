require 'test_helper'

class FunctionTest < MiniTest::Unit::TestCase

  def test_fun_without_args
    parses "->\n 3\n end" do |nodes|
      fun = nodes.first

      assert_kind_of Function, fun
      assert_equal [], fun.params

      body = fun.body.nodes
      assert_equal [Integer.new(3)], body
    end
  end

  def test_fun_with_one_param
    parses "-> bar; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of Function, fun
      assert_equal [Identifier.new('bar')], fun.params

      body = fun.body.nodes
      assert_equal [Integer.new(3)], body
    end
  end

  def test_fun_with_multiple_params
    parses "-> bar, baz; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of Function, fun
      assert_equal [Identifier.new('bar'), Identifier.new('baz')], fun.params

      body = fun.body.nodes
      assert_equal [Integer.new(3)], body
    end
  end

  def test_fun_with_default_param
    parses "-> bar, baz='ho'; 3; end" do |nodes|
      fun = nodes.first

      assert_kind_of Function, fun
      assert_equal [
        Identifier.new('bar'),
        DefaultParameter.new(
          Identifier.new('baz'),
          String.new('ho')
        )
      ], fun.params

      body = fun.body.nodes
      assert_equal [Integer.new(3)], body
    end
  end
end
