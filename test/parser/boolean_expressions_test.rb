require 'test_helper'

class BooleanExpressionsTest < MiniTest::Unit::TestCase

  def test_equality
    parses "foo == 3" do |nodes|
      exp = nodes.first

      assert_kind_of EqualityExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Integer.new(3), exp.rhs
    end
  end

  def test_inequality
    parses "foo != 3" do |nodes|
      exp = nodes.first

      assert_kind_of InequalityExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Integer.new(3), exp.rhs
    end
  end

  def test_gt
    parses "foo > 3" do |nodes|
      exp = nodes.first

      assert_kind_of GtExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Integer.new(3), exp.rhs
    end
  end

  def test_gte
    parses "foo >= 3" do |nodes|
      exp = nodes.first

      assert_kind_of GteExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Integer.new(3), exp.rhs
    end
  end

  def test_lt
    parses "foo < 3" do |nodes|
      exp = nodes.first

      assert_kind_of LtExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Integer.new(3), exp.rhs
    end
  end

  def test_lte
    parses "foo <= 3" do |nodes|
      exp = nodes.first

      assert_kind_of LteExpression, exp
      assert_equal Identifier.new('foo'), exp.lhs
      assert_equal Integer.new(3), exp.rhs
    end
  end
end
