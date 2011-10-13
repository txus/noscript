require 'test_helper'

class BooleansTest < MiniTest::Unit::TestCase

  def test_true
    parses "true" do |nodes|
      exp = nodes.first
      assert_equal True.new, exp
    end
  end

  def test_false
    parses "false" do |nodes|
      exp = nodes.first
      assert_equal False.new, exp
    end
  end

  def test_nil
    parses "nil" do |nodes|
      exp = nodes.first
      assert_equal Nil.new, exp
    end
  end
end
