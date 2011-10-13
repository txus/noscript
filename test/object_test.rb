require 'test_helper'

class ObjectTest < MiniTest::Unit::TestCase

  def setup
    @object = Object.new
    @context = Context.new
  end

  def test_clone
    child = @object.send('clone').call(@context)

    assert_equal(@object, child.parent)
    assert_includes(child.slots.keys, 'clone')
  end

  def test_clone_with_tuple
    tuple = Tuple.new({
      'foo' => Integer.new(99),
      'bar' => String.new('hey'),
    })
    child = @object.send('clone').call(@context, tuple)

    assert_equal(@object, child.parent)
    assert_includes(child.slots.keys, 'clone')

    assert_equal Integer.new(99), child.send('foo')
    assert_equal String.new('hey'), child.send('bar')
  end

  def test_uses
    trait = Trait.new(Tuple.new({
      'foo' => lambda { |*| Integer.new(3) }
    }))
    @context.store_var('FooTrait', trait)
    @object.send('uses').call(@context, Identifier.new('FooTrait'))

    assert_equal Integer.new(3), @object.send('foo').call(@context)
  end

  def test_each_slot
    results = {}
    @fun = lambda { |k, v| results[k.to_s] = v.to_i * 2 }
    def @fun.compile(*); self; end

    @object.add_slot('foo', Integer.new(90))
    @object.add_slot('bar', Integer.new(20))

    @object.send('each slot').call(@context, @fun)

    assert_equal 180, results['foo']
    assert_equal 40, results['bar']
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
    assert_raises Exception do
      @object.send('bar')
    end
  end

  def test_add_slot
    @object.add_slot('foo', 'bar')
    assert_equal 'bar', @object.slots['foo']
  end

end
