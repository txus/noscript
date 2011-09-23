require 'test_helper'

class FunctionTest < MiniTest::Unit::TestCase

  def setup
    @context = Noscript::Context.new

    # Define this function:
    #
    # -> bar=23
    #   a = 3
    #   74
    # end
    @function = Noscript::AST::Function.new(
      # PARAMS
      [
        Noscript::AST::DefaultParameter.new(
          Noscript::AST::Identifier.new('bar'),
          Noscript::AST::Integer.new(23)
        )
      ],

      # BODY
      Noscript::AST::Nodes.new([
        Noscript::AST::Assignment.new(
          nil,
          Noscript::AST::Identifier.new('a'),
          Noscript::AST::Integer.new(3)
        ),
        Noscript::AST::Integer.new(74)
      ])
    )
  end

  def test_function_returns_last_value
    assert_equal Noscript::AST::Integer.new(74), @function.call(@context)
  end

  def test_function_local_scope
    @function.call(@context)
    assert_nil @context.lvars['a']
  end

  def test_function_using_default_param
    # Add a last line to the body:
    #
    # bar + 2
    #
    @function.body.nodes.push(
      Noscript::AST::AddNode.new(
        Noscript::AST::Identifier.new('bar'),
        Noscript::AST::Integer.new(2),
      )
    )
    assert_equal Noscript::AST::Integer.new(25), @function.call(@context)
  end

  def test_function_overriding_default_param
    # Add a last line to the body:
    #
    # bar + 2
    #
    @function.body.nodes.push(
      Noscript::AST::AddNode.new(
        Noscript::AST::Identifier.new('bar'),
        Noscript::AST::Integer.new(2),
      )
    )
    assert_equal Noscript::AST::Integer.new(100), @function.call(@context, Noscript::AST::Integer.new(98))
  end

  def test_function_using_local_var
    # Add a last line to the body:
    #
    # a + 2
    #
    @function.body.nodes.push(
      Noscript::AST::AddNode.new(
        Noscript::AST::Identifier.new('a'),
        Noscript::AST::Integer.new(2),
      )
    )
    assert_equal Noscript::AST::Integer.new(5), @function.call(@context)
  end

  def test_function_with_too_few_arguments
    # -> bar
    # end
    @function = Noscript::AST::Function.new(
      # ARGUMENTS
      [ Noscript::AST::Identifier.new('bar') ],

      # BODY
      Noscript::AST::Nodes.new([])
    )

    @function.pos('file', '1')

    assert_raises Noscript::ArgumentError, "This function expected 1 arguments, not 0 [file:1]" do
      @function.call(@context)
    end
  end

  def test_function_with_too_many_arguments
    assert_raises Noscript::ArgumentError, "This function expected 1 arguments, not 2 [file:1]" do
      @function.pos('file', '1')
      @function.call(@context, Noscript::AST::Integer.new(10), Noscript::AST::Integer.new(9))
    end
  end

  def test_function_with_dereferencing
    # -> bar=23
    #   a = 3
    #   74
    #   @foo
    # end
    @function.body.nodes.push(
      Noscript::AST::Identifier.new('foo', true)
    )
    object = Noscript::Object.new
    object.add_slot('foo', Noscript::AST::Integer.new(123))

    @context.current_receiver = object

    assert_equal Noscript::AST::Integer.new(123), @function.call(@context)
  end

  def test_function_with_dereferencing_on_the_call
    # foo = -> bar=23
    #   a = 3
    #   74
    #   bar
    # end
    #
    # foo(@baz)
    @function.body.nodes.push(
      Noscript::AST::Identifier.new('bar')
    )
    object = Noscript::Object.new
    object.add_slot('baz', Noscript::AST::Integer.new(123))

    @context.current_receiver = object

    assert_equal Noscript::AST::Integer.new(123), @function.call(@context, Noscript::AST::Identifier.new('baz', true))
  end

end
