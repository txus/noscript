require 'test_helper'

class BooleansTest < MiniTest::Unit::TestCase
  def test_true
    parses "true" do |nodes|
      exp = nodes.first
      assert_kind_of TrueLiteral, exp
    end
  end

  def test_false
    parses "false" do |nodes|
      exp = nodes.first
      assert_kind_of FalseLiteral, exp
    end
  end

  def test_nil
    parses "nil" do |nodes|
      exp = nodes.first
      assert_kind_of NilLiteral, exp
    end
  end
end
