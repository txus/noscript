require 'test_helper'

class NoscriptTest < MiniTest::Unit::TestCase

  def test_hello_world
    output = `./bin/noscript examples/hello_world.ns`.split("\n")

    assert_equal [
      "Negative johnny is",
      "-4000",
      "43",
      "760",
      "111",
      "cool!",
      "bar",
      "baz",
      "Johnny is still",
      "4000",
      "lord",
      "hello world",
    ], output
  end

  def test_objects
    output = `./bin/noscript examples/objects.ns`.split("\n")

    assert_equal [
      "running!",
      "10",
    ], output
  end

  def test_traits
    output = `./bin/noscript examples/traits.ns`.split("\n")

    assert_equal [
      "John",
      "is running with traits at speed:",
      "10"
    ], output
  end

  def test_conditionals
    [
      """
        foo = 3

        if foo != 91
          'ok'
        end
      """,

      """
        foo = 3

        if foo > 2
          'ok'
        else
          'ko'
        end
      """,

      """
        foo = 3

        if foo < 2
          'ko'
        else
          'ok'
        end
      """,

      """
        foo = 3

        if foo <= 3
          'ok'
        else
          'ko'
        end
      """,

      """
        foo = 4

        if foo >= 3
          'ok'
        else
          'ko'
        end
      """
    ].each do |code|
      compiles(code) do |retval|
        assert_equal Noscript::AST::String.new('ok'), retval
      end
    end
  end

  def test_while
    [
      """
        foo = 3

        while foo > 0
          foo = foo - 1
        end

        foo
      """
    ].each do |code|
      compiles(code) do |retval|
        assert_equal Noscript::AST::Digit.new('1'), retval
      end
    end
  end

end
