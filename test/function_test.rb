require 'test_helper'

class FunctionTest < MiniTest::Unit::TestCase

  def setup
    @context = Context.new

    # Define this function:
    #
    # -> bar=23
    #   a = 3
    #   74
    # end
    @function = Function.new(
      # PARAMS
      [
        DefaultParameter.new(
          Identifier.new('bar'),
          Integer.new(23)
        )
      ],

      # BODY
      Nodes.new([
        Assignment.new(
          nil,
          Identifier.new('a'),
          Integer.new(3)
        ),
        Integer.new(74)
      ])
    )
  end

  def test_function_returns_last_value
    assert_equal Integer.new(74), @function.call(@context)
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
      AddNode.new(
        Identifier.new('bar'),
        Integer.new(2),
      )
    )
    assert_equal Integer.new(25), @function.call(@context)
  end

  def test_function_overriding_default_param
    # Add a last line to the body:
    #
    # bar + 2
    #
    @function.body.nodes.push(
      AddNode.new(
        Identifier.new('bar'),
        Integer.new(2),
      )
    )
    assert_equal Integer.new(100), @function.call(@context, Integer.new(98))
  end

  def test_function_using_local_var
    # Add a last line to the body:
    #
    # a + 2
    #
    @function.body.nodes.push(
      AddNode.new(
        Identifier.new('a'),
        Integer.new(2),
      )
    )
    assert_equal Integer.new(5), @function.call(@context)
  end

  def test_function_with_too_few_arguments
    # -> bar
    # end
    @function = Function.new(
      # ARGUMENTS
      [ Identifier.new('bar') ],

      # BODY
      Nodes.new([])
    )

    @function.pos('file', '1')

    assert_raises ArgumentError, "This function expected 1 arguments, not 0 [file:1]" do
      @function.call(@context)
    end
  end

  def test_function_with_too_many_arguments
    assert_raises ArgumentError, "This function expected 1 arguments, not 2 [file:1]" do
      @function.pos('file', '1')
      @function.call(@context, Integer.new(10), Integer.new(9))
    end
  end

  def test_function_with_dereferencing
    # -> bar=23
    #   a = 3
    #   74
    #   @foo
    # end
    @function.body.nodes.push(
      Identifier.new('foo', true)
    )
    object = Object.new
    object.add_slot('foo', Integer.new(123))

    @context.current_receiver = object

    assert_equal Integer.new(123), @function.call(@context)
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
      Identifier.new('bar')
    )
    object = Object.new
    object.add_slot('baz', Integer.new(123))

    @context.current_receiver = object

    assert_equal Integer.new(123), @function.call(@context, Identifier.new('baz', true))
  end

end
