require 'test_helper'

class TraitListTest < MiniTest::Unit::TestCase

  def setup
    @trait_list = Noscript::TraitList.new
    @trait = Noscript::Trait.new(Noscript::AST::Tuple.new({'foo' => 'bar', 'bar' => 'baz'}))
    @another_trait = Noscript::Trait.new(Noscript::AST::Tuple.new({'foo' => 'bar', 'hey' => 'ho'}))
  end

  def test_add_trait
    @trait_list.push(@trait, 'Runnable')
    assert_includes @trait_list, @trait
  end

  def test_conflicts
    @trait_list.push(@trait, 'Runnable')
    assert_raises Noscript::Exception do
      @trait_list.push(@another_trait, 'Executable')
    end
  end

end
