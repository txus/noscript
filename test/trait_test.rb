require 'test_helper'

class TraitTest < MiniTest::Unit::TestCase

  def setup
    @method_foo = Noscript::Method.new(
      # Params
      [Noscript::AST::Identifier.new('foo')],

      # Body
      Noscript::AST::Nodes.new([
        Noscript::AST::Digit.new(3)
      ])
    )

    @method_bar = Noscript::Method.new(
      # Params
      [],

      # Body
      Noscript::AST::Nodes.new([
        Noscript::AST::Digit.new(10)
      ])
    )

    @trait = Noscript::Trait.new(Noscript::AST::Tuple.new({
      'foo' => @method_foo,
      'bar' => @method_bar
    }))
  end

  def test_initialize
    assert_equal(Noscript::AST::Tuple.new({
      'foo' => @method_foo,
      'bar' => @method_bar
    }), @trait.slots)
  end

  def test_implements
    assert @trait.implements?('foo')
    refute @trait.implements?('johnny')
  end
end
