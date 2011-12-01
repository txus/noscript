require 'test_helper'

class TraitTest < MiniTest::Unit::TestCase

  # def setup
  #   @method_foo = Function.new(
  #     # Params
  #     [Identifier.new('foo')],

  #     # Body
  #     Nodes.new([
  #       Integer.new(3)
  #     ])
  #   )

  #   @method_bar = Function.new(
  #     # Params
  #     [],

  #     # Body
  #     Nodes.new([
  #       Integer.new(10)
  #     ])
  #   )

  #   @trait = Noscript::Trait.new(Tuple.new({
  #     'foo' => @method_foo,
  #     'bar' => @method_bar
  #   }))
  # end

  # def test_initialize
  #   assert_equal(Tuple.new({
  #     'foo' => @method_foo,
  #     'bar' => @method_bar
  #   }), @trait.slots)
  # end

  # def test_implements
  #   assert @trait.implements?('foo')
  #   refute @trait.implements?('johnny')
  # end

  # def test_get_direct_message
  #   assert_kind_of Function, @trait.get('foo')
  # end
end
