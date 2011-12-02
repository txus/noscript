require 'test_helper'

class JavascriptGeneratorTest < MiniTest::Unit::TestCase
  def test_assignment
    compiler = Compiler.new(Noscript::JavascriptGenerator)
    compiler.compile("a = 1").must_equal(
      "var a;\na = 1;")
  end

  def test_function_literal
    compiler = Compiler.new(Noscript::JavascriptGenerator)
    compiler.compile("a = -> b, c\n  b + c\nend").must_equal(
      "var a;\na = function(b, c) {\nb + c;\n};")
  end
end
