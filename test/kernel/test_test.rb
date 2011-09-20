require 'test_helper'

class TestTest < MiniTest::Unit::TestCase

  def test_assert_returns_true
    code = <<-CODE
    foo = true
    Test.assert(foo)
CODE

    assert_equal Noscript::AST::True.new, compiles(code)
  end

  def test_assert_raises
    code = <<-CODE
    foo = false
    Test.assert(foo)
CODE

    assert_raises Noscript::AST::Exception do
      compiles(code)
    end
  end

  def test_assert_equal_returns_true
    code = <<-CODE
    Test.assert equal(1, 1)
CODE

    assert_equal Noscript::AST::True.new, compiles(code)
  end

  def test_assert_equal_raises
    code = <<-CODE
    Test.assert equal(3, 2)
CODE

    assert_raises Noscript::AST::Exception do
      compiles(code)
    end
  end
end
