require 'test_helper'

class ArrayTest < MiniTest::Unit::TestCase

  def test_empty_array
    parses "[]" do |nodes|
      array = nodes.first

      assert_kind_of Array, array
      assert_equal([], array.body)
    end
  end

  def test_array_with_one_element
    parses "[1]" do |nodes|
      array = nodes.first

      assert_kind_of Array, array
      assert_equal([Integer.new(1)], array.body)
    end
  end

  def test_array_with_multiple_elements
    parses "[1, 2]" do |nodes|
      array = nodes.first

      assert_kind_of Array, array
      assert_equal([Integer.new(1), Integer.new(2)], array.body)
    end
  end

  def test_array_with_multiple_identifiers
    parses "[foo, bar]" do |nodes|
      array = nodes.first

      assert_kind_of Array, array
      assert_equal([Identifier.new('foo'), Identifier.new('bar')], array.body)
    end
  end

  def test_array_multiline
    parses "[
      foo,
      bar
    ]" do |nodes|
      array = nodes.first

      assert_kind_of Array, array
      assert_equal([Identifier.new('foo'), Identifier.new('bar')], array.body)
    end
  end

end
