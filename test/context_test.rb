require 'test_helper'

class ContextTest < MiniTest::Unit::TestCase

  def setup
    @context = Noscript::Context.new
    @context.lvars   = { 'foo' => 3 }
    @context.methods = { 'lorem' => proc { 'ipsum' } }
  end

  # Local variable lookup and storage

  def test_lookup_var
    assert_equal 3, @context.lookup_var('foo')
  end

  def test_lookup_var_fails
    assert_raises RuntimeError, 'Undefined local variable: bar' do
      @context.lookup_var('bar')
    end
  end

  def test_lookup_var_climbs_up_the_scope_chain
    parent_context = Noscript::Context.new
    parent_context.lvars = { 'bar' => 9 }

    child_context = Noscript::Context.new(parent_context)

    assert_equal 9, child_context.lookup_var('bar')
  end

  def test_store_var
    @context.store_var(:baz, 3)
    assert_equal 3, @context.lvars['baz']
  end

  # Method lookup and storage

  def test_lookup_method
    assert_equal 'ipsum', @context.lookup_method('lorem').call
  end

  def test_lookup_method_fails
    assert_raises RuntimeError, 'Undefined method: dolor' do
      @context.lookup_method('dolor')
    end
  end

  def test_lookup_method_climbs_up_the_scope_chain
    parent_context = Noscript::Context.new
    parent_context.methods = { 'sit' => proc { 'amet' } }

    child_context = Noscript::Context.new(parent_context)

    assert_equal 'amet', child_context.lookup_method('sit').call
  end

  def test_store_method
    @context.store_method(:sit, [:bar, :baz], proc { 'amet' })

    method = @context.methods['sit']
    assert_equal [:bar, :baz], method.params
    assert_equal 'amet', method.body.call
  end

  def test_store_ruby_method
    @context.store_ruby_method(:amet) do
      'consectetur'
    end

    method = @context.methods['amet']
    assert_equal 'consectetur', method.call
  end

end