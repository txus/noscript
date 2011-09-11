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
      "828",
      "Johnny is still",
      "4000",
      "'hello world'",
    ], output
  end

end
