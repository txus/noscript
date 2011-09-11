require 'test_helper'

class DefMethodTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_def_method_without_params
    parses "def foo(); 3; end" do |nodes|
      def_method = nodes.first

      assert_kind_of DefMethod, def_method
      assert_equal 'foo', def_method.name
      assert_equal [], def_method.params

      body = def_method.body.nodes
      assert_equal [Digit.new(3)], body
    end
  end

  def test_def_method_with_one_param
    parses "def foo(bar); 3; end" do |nodes|
      def_method = nodes.first

      assert_kind_of DefMethod, def_method
      assert_equal 'foo', def_method.name
      assert_equal [Identifier.new('bar')], def_method.params

      body = def_method.body.nodes
      assert_equal [Digit.new(3)], body
    end
  end

  def test_def_method_with_multiple_params
    parses "def foo(bar, baz); 3; end" do |nodes|
      def_method = nodes.first

      assert_kind_of DefMethod, def_method
      assert_equal 'foo', def_method.name
      assert_equal [Identifier.new('bar'), Identifier.new('baz')], def_method.params

      body = def_method.body.nodes
      assert_equal [Digit.new(3)], body
    end
  end

  def test_def_method_with_default_param
    parses "def foo(bar, baz='ho'); 3; end" do |nodes|
      def_method = nodes.first

      assert_kind_of DefMethod, def_method
      assert_equal 'foo', def_method.name
      assert_equal [
        Identifier.new('bar'),
        DefaultParameter.new(
          Identifier.new('baz'),
          String.new('ho')
        )
      ], def_method.params

      body = def_method.body.nodes
      assert_equal [Digit.new(3)], body
    end
  end
end
