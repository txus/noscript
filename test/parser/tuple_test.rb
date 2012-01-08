require 'test_helper'

class TupleTest < MiniTest::Unit::TestCase

  def test_empty_tuple
    parses "{}" do |nodes|
      tuple = nodes.first

      assert_kind_of HashLiteral, tuple
      assert_equal([], tuple.array)
    end
  end

  def test_tuple_with_one_element
    parses "{a: 1}" do |nodes|
      tuple = nodes.first

      assert_kind_of HashLiteral, tuple
      body = tuple.array
      assert_equal 'a', body.first.string
      assert_equal 1, body.last.value
    end
  end

  def test_tuple_with_multiple_elements
    parses "{a: 1, b: 2}" do |nodes|
      tuple = nodes.first

      assert_kind_of HashLiteral, tuple
      body = tuple.array
      assert_equal 'a', body[0].string
      assert_equal 1, body[1].value

      assert_equal 'b', body[2].string
      assert_equal 2, body[3].value
    end
  end

  def test_tuple_multiline
    parses "{
    a: 1,

    b: 2

    }" do |nodes|
      tuple = nodes.first

      assert_kind_of HashLiteral, tuple
      body = tuple.array
      assert_equal 'a', body[0].string
      assert_equal 1, body[1].value

      assert_equal 'b', body[2].string
      assert_equal 2, body[3].value
    end
  end

end
