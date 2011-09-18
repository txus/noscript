require 'test_helper'

class ObjectTest < MiniTest::Unit::TestCase

  def setup
    @object = Noscript::Object.new
    @context = Noscript::Context.new
  end

  def test_clone
    child = @object.send('clone').call(@context)

    assert_equal(@object, child.parent)
    assert_includes(child.slots.keys, 'clone')
  end

  def test_uses
    trait = Noscript::Trait.new({
      'foo' => lambda { |*| Noscript::AST::Digit.new(3) }
    })
    @context.store_var('FooTrait', trait)
    @object.send('uses').call(@context, Noscript::AST::Identifier.new('FooTrait'))

    assert_equal Noscript::AST::Digit.new(3), @object.send('foo').call(@context)
  end

  def test_send_matches_child
    child = @object.clone
    child.slots['foo'] = 'bar'

    assert_equal 'bar', child.send('foo')
  end

  def test_send_matches_parent
    @object.slots['foo'] = 'bar'
    child = @object.clone

    assert_equal 'bar', child.send('foo')
  end

  def test_send_raises_when_inexistent_slot
    assert_raises RuntimeError do
      @object.send('bar')
    end
  end

  def test_add_slot
    @object.add_slot('foo', 'bar')
    assert_equal 'bar', @object.slots['foo']
  end

end
