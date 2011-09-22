require 'test_helper'

class StringInterpolationTest < MiniTest::Unit::TestCase

  def setup
    @context = Noscript::Context.new
    @context.store_var('foo', Noscript::AST::Digit.new(3))
  end

  def test_string_interpolation
    @string = Noscript::AST::String.new(
      'Hello people, we just bought #{foo} interpolations'
    )
    assert_equal "Hello people, we just bought 3 interpolations", @string.compile(@context).to_s
  end
end
