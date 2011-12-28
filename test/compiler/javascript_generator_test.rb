require 'test_helper'

class JavascriptGeneratorTest < MiniTest::Unit::TestCase
  def test_assignment
    compiler = Compiler.new(Noscript::JavascriptGenerator)
    assert_equal "var a;\na = 1;",
      compiler.compile("a = 1")
  end

  def test_function_literal
    compiler = Compiler.new(Noscript::JavascriptGenerator)
    assert_equal "var a;\na = function(b, c) {\n  b + c;\n};",
      compiler.compile("a = -> b, c\n  b + c\nend")
  end

  def test_hey
    compiler = Compiler.new(Noscript::JavascriptGenerator)
    compiler.compile(File.read("examples/hello_world.ns"))
  end
end
