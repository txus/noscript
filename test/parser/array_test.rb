require 'test_helper'

class ArrayTest < MiniTest::Unit::TestCase

  def test_empty_array
    parses "[]" do |nodes|
      array = nodes.first

      assert_kind_of ArrayNode, array
      assert_equal([], array.value)
    end
  end

  def test_array_with_one_element
    parses "[1]" do |nodes|
      array = nodes.first

      assert_kind_of ArrayNode, array
      assert_equal(1, array.value.first.value)
    end
  end

  def test_array_with_multiple_elements
    parses "[1, 2]" do |nodes|
      array = nodes.first

      assert_kind_of ArrayNode, array
      assert_equal([1, 2], array.value.map(&:value))
    end
  end

  def test_array_with_multiple_identifiers
    parses "[foo, bar]" do |nodes|
      array = nodes.first

      assert_kind_of ArrayNode, array
      assert_equal(['foo', 'bar'], array.value)
    end
  end

  def test_array_multiline
    parses "[
      \"foo\",
      34
    ]" do |nodes|
      array = nodes.first

      assert_kind_of ArrayNode, array
      assert_equal(["foo", 34], array.value.map(&:value))
    end
  end

end
