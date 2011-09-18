require 'test_helper'

class LexerTest < MiniTest::Unit::TestCase

  def test_newline
    tokenizes "\n", [[:NEWLINE, "\n"]]
    tokenizes "\n ", [[:NEWLINE, "\n "]]
    tokenizes "\n\n ", [[:NEWLINE, "\n\n "]]
    tokenizes "\n\n  ", [[:NEWLINE, "\n\n  "]]
  end

  def test_ignores_whitespace
    tokenizes " ", []
    tokenizes ", ", [[:COMMA, ',']]
  end

  def test_digit
    tokenizes "3", [[:DIGIT, 3]]
    tokenizes "3234", [[:DIGIT, 3234]]
  end

  def test_assign
    tokenizes "=", [[:ASSIGN, '=']]
  end

  def test_comma
    tokenizes ",", [[:COMMA, ',']]
  end

  def test_semicolon
    tokenizes ";", [[:SEMICOLON, ';']]
  end

  def test_string
    tokenizes "'foo'", [[:STRING, 'foo']]
  end

  def test_lparen
    tokenizes "(", [[:LPAREN, '(']]
  end

  def test_rparen
    tokenizes ")", [[:RPAREN, ')']]
  end

  def test_end
    tokenizes "end", [[:END, 'end']]
  end

  def test_if
    tokenizes "if", [[:IF, 'if']]
  end

  def test_else
    tokenizes "else", [[:ELSE, 'else']]
  end

  def test_while
    tokenizes "while", [[:WHILE, 'while']]
  end

  # Boolean operators

  def test_boolean_operators
    tokenizes "==", [[:EQUALS, '==']]
    tokenizes "!=", [[:NEQUALS, '!=']]
    tokenizes "<", [[:LT_OP, '<']]
    tokenizes "<=", [[:LTE_OP, '<=']]
    tokenizes ">", [[:GT_OP, '>']]
    tokenizes ">=", [[:GTE_OP, '>=']]
  end

  def test_booleans
    tokenizes "true", [[:TRUE, 'true']]
    tokenizes "false", [[:FALSE, 'false']]
    tokenizes "nil", [[:NIL, 'nil']]
  end

  def test_identifier
    tokenizes "hello", [[:IDENTIFIER, 'hello']]
    tokenizes "hello_world", [[:IDENTIFIER, 'hello_world']]
    tokenizes "hello world", [[:IDENTIFIER, 'hello world']]
    tokenizes "goodbye cruel world", [[:IDENTIFIER, 'goodbye cruel world']]
    tokenizes "_hey", [[:IDENTIFIER, '_hey']]
  end

  def test_everything_else
    %w(+ - * / ^ & { } [ ]).each do |symbol|
      tokenizes symbol, [[symbol, symbol]]
    end
  end

  def test_fun
    tokenizes "->", [[:FUN, '->']]
  end

end
