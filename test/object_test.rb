require 'test_helper'

class ObjectTest < MiniTest::Unit::TestCase

  def setup
    @object = Noscript::Object.new
  end

  def test_clone
    @object.slots['hey'] = 3
    child = @object.clone

    assert_equal(@object, child.parent)
    assert_equal({}, child.slots)
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
