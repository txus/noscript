require 'test_helper'

class TupleTest < MiniTest::Unit::TestCase

  include Noscript::AST

  def test_empty_tuple
    parses "{}" do |nodes|
      tuple = nodes.first

      assert_kind_of Tuple, tuple
      assert_equal({}, tuple.body)
    end
  end

  def test_tuple_with_one_element
    parses "{a: 1}" do |nodes|
      tuple = nodes.first

      assert_kind_of Tuple, tuple
      assert_equal({'a' => Integer.new(1)}, tuple.body)
    end
  end

  def test_tuple_with_multiple_elements
    parses "{a: 1, b: 2}" do |nodes|
      tuple = nodes.first

      assert_kind_of Tuple, tuple
      assert_equal({'a' => Integer.new(1), 'b' => Integer.new(2)}, tuple.body)
    end
  end

  def test_tuple_with_multiple_identifiers
    parses "{a: foo, b: bar}" do |nodes|
      tuple = nodes.first

      assert_kind_of Tuple, tuple
      assert_equal({'a' => Identifier.new('foo'), 'b' => Identifier.new('bar')}, tuple.body)
    end
  end

  def test_tuple_multiline
    parses "{
      a: foo,
      b: bar
    }" do |nodes|
      tuple = nodes.first

      assert_kind_of Tuple, tuple
      assert_equal({'a' => Identifier.new('foo'), 'b' => Identifier.new('bar')}, tuple.body)
    end
  end

end
