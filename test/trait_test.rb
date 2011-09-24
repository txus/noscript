require 'test_helper'

class TraitTest < MiniTest::Unit::TestCase

  def setup
    @method_foo = Noscript::AST::Function.new(
      # Params
      [Noscript::AST::Identifier.new('foo')],

      # Body
      Noscript::AST::Nodes.new([
        Noscript::AST::Integer.new(3)
      ])
    )

    @method_bar = Noscript::AST::Function.new(
      # Params
      [],

      # Body
      Noscript::AST::Nodes.new([
        Noscript::AST::Integer.new(10)
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

  def test_get_direct_message
    assert_kind_of Noscript::AST::Function, @trait.get('foo')
  end
end
