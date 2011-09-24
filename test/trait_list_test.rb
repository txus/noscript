require 'test_helper'

class TraitListTest < MiniTest::Unit::TestCase

  def setup
    @object = Noscript::Object.new
    @trait_list = Noscript::TraitList.new(@object)
    @trait = Noscript::Trait.new(Noscript::AST::Tuple.new({'foo ho' => 'bar', 'bar' => 'baz', 'hey' => 'ho'}))
    @another_trait = Noscript::Trait.new(Noscript::AST::Tuple.new({'foo ho' => 'bey', 'hey' => 'ho'}))

    @trait_list.push(@trait, 'Runnable')
  end

  def test_add_trait
    assert_includes @trait_list, @trait
  end

  def test_conflicts
    assert_raises Noscript::Exception do
      @trait_list.push(@another_trait, 'Executable')
    end
  end

  def test_does_not_conflict_if_owner_resolves_conflicts_by_implementing_messages
    @object.add_slot('foo ho', 1)
    @object.add_slot('hey', 2)
    @trait_list.push(@another_trait, 'Executable')
  end

  def test_lookup_implicit_message
    assert_equal 'bar', @trait_list.lookup('foo ho')
  end

  def test_lookup_explicit_message
    assert_equal 'bar', @trait_list.lookup('Runnable foo ho')
  end

end
