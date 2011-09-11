require 'test_helper'

class LexerIntegrationTest < MiniTest::Unit::TestCase

  def test_assignment
    tokenizes "foo = 'bar'", [
      [:IDENTIFIER, 'foo'],
      [:ASSIGN, '='],
      [:STRING, 'bar'],
    ]
  end

  def test_arithmetic_assignment
    tokenizes "foo = (3 + 4) * 2", [
      [:IDENTIFIER, 'foo'],
      [:ASSIGN, '='],
      [:LPAREN, '('],
      [:DIGIT, 3],
      ['+', '+'],
      [:DIGIT, 4],
      [:RPAREN, ')'],
      ['*', '*'],
      [:DIGIT, 2],
    ]
  end

  def test_def_single_line
    tokenizes "def foo(bar, baz); 'lorem'; end", [
      [:DEF, 'def'],
      [:IDENTIFIER, 'foo'],
      [:LPAREN, '('],
      [:IDENTIFIER, 'bar'],
      [:COMMA, ','],
      [:IDENTIFIER, 'baz'],
      [:RPAREN, ')'],
      [:SEMICOLON, ';'],
      [:STRING, "lorem"],
      [:SEMICOLON, ';'],
      [:END, "end"],
    ]
  end

  def test_def_multiline
    tokenizes "def foo(bar, baz)\n 'lorem'\n end", [
      [:DEF, 'def'],
      [:IDENTIFIER, 'foo'],
      [:LPAREN, '('],
      [:IDENTIFIER, 'bar'],
      [:COMMA, ','],
      [:IDENTIFIER, 'baz'],
      [:RPAREN, ')'],
      [:NEWLINE, "\n "],
      [:STRING, "lorem"],
      [:NEWLINE, "\n "],
      [:END, "end"],
    ]
  end

end
