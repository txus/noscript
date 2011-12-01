require 'test_helper'

class TupleTest < MiniTest::Unit::TestCase

  def test_empty_tuple
    parses "{}" do |nodes|
      tuple = nodes.first

      assert_kind_of TupleNode, tuple
      assert_equal({}, tuple.value)
    end
  end

  def test_tuple_with_one_element
    parses "{a: 1}" do |nodes|
      tuple = nodes.first

      assert_kind_of TupleNode, tuple
      assert_equal(['a'], tuple.value.keys)
      assert_equal([1], tuple.value.values.map(&:value))
    end
  end

  def test_tuple_with_multiple_elements
    parses "{a: 1, b: 2}" do |nodes|
      tuple = nodes.first

      assert_kind_of TupleNode, tuple
      assert_equal(['a', 'b'], tuple.value.keys)
      assert_equal([1, 2], tuple.value.values.map(&:value))
    end
  end

  def test_tuple_multiline
    parses "{
    a: 1,

    b: 2

    }" do |nodes|
      tuple = nodes.first

      assert_kind_of TupleNode, tuple
      assert_equal(['a', 'b'], tuple.value.keys)
      assert_equal([1, 2], tuple.value.values.map(&:value))
    end
  end

end
