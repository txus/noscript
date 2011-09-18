require 'test_helper'

class MethodTest < MiniTest::Unit::TestCase

  def setup
    @context = Noscript::Context.new

    # Define this function:
    #
    # -> bar=23
    #   a = 3
    #   74
    # end
    @method = Noscript::Method.new(
      # PARAMS
      [
        Noscript::AST::DefaultParameter.new(
          Noscript::AST::Identifier.new('bar'),
          Noscript::AST::Digit.new(23)
        )
      ],

      # BODY
      Noscript::AST::Nodes.new([
        Noscript::AST::AssignNode.new(
          nil,
          Noscript::AST::Identifier.new('a'),
          Noscript::AST::Digit.new(3)
        ),
        Noscript::AST::Digit.new(74)
      ])
    )
  end

  def test_method_returns_last_value
    assert_equal Noscript::AST::Digit.new(74), @method.call(@context)
  end

  def test_method_local_scope
    @method.call(@context)
    assert_nil @context.lvars['a']
  end

  def test_method_using_default_param
    # Add a last line to the body:
    #
    # bar + 2
    #
    @method.body.nodes.push(
      Noscript::AST::AddNode.new(
        Noscript::AST::Identifier.new('bar'),
        Noscript::AST::Digit.new(2),
      )
    )
    assert_equal Noscript::AST::Digit.new(25), @method.call(@context)
  end

  def test_method_overriding_default_param
    # Add a last line to the body:
    #
    # bar + 2
    #
    @method.body.nodes.push(
      Noscript::AST::AddNode.new(
        Noscript::AST::Identifier.new('bar'),
        Noscript::AST::Digit.new(2),
      )
    )
    assert_equal Noscript::AST::Digit.new(100), @method.call(@context, Noscript::AST::Digit.new(98))
  end

  def test_method_using_local_var
    # Add a last line to the body:
    #
    # a + 2
    #
    @method.body.nodes.push(
      Noscript::AST::AddNode.new(
        Noscript::AST::Identifier.new('a'),
        Noscript::AST::Digit.new(2),
      )
    )
    assert_equal Noscript::AST::Digit.new(5), @method.call(@context)
  end

  def test_method_with_too_few_arguments
    # -> bar
    # end
    @method = Noscript::Method.new(
      # ARGUMENTS
      [ Noscript::AST::Identifier.new('bar') ],

      # BODY
      Noscript::AST::Nodes.new([])
    )
    assert_raises RuntimeError, "This function expected 1 arguments, not 0" do
      @method.call(@context)
    end
  end

  def test_method_with_too_many_arguments
    assert_raises RuntimeError, "This function expected 1 arguments, not 2" do
      @method.call(@context, Noscript::AST::Digit.new(10), Noscript::AST::Digit.new(9))
    end
  end

end
