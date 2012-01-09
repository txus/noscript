require 'test_helper'

class LexerTest < MiniTest::Unit::TestCase

  def test_ignores_comments_and_whitespace
    tokenizes "  # hey  ", []
  end

  def test_newline
    tokenizes "\n", [[:NEWLINE, "\n"]]
    tokenizes "\n\n", [[:NEWLINE, "\n"], [:NEWLINE, "\n"]]
  end

  def test_integer
    tokenizes "3", [[:INTEGER, 3]]
    tokenizes "3234", [[:INTEGER, 3234]]
  end

  def test_string
    tokenizes "'foo'",   [[:STRING, 'foo']]
    tokenizes "\"foo\"", [[:STRING, 'foo']]
  end

  def test_keywords
    %w(end if else while true false nil).each do |keyword|
      tokenizes "#{keyword}", [
        [keyword.upcase.to_sym, keyword]
      ]
    end
  end

  def test_identifiers_and_constants
    tokenizes "foo", [[:IDENTIFIER, 'foo']]
    tokenizes "hello", [[:IDENTIFIER, 'hello']]
    tokenizes "hello_world", [[:IDENTIFIER, 'hello_world']]
    tokenizes "hello world", [[:IDENTIFIER, 'hello world']]
    tokenizes "My constant+", [[:IDENTIFIER, 'My constant'], ['+', '+']]
    tokenizes "goodbye cruel world", [[:IDENTIFIER, 'goodbye cruel world']]
    tokenizes "@name", [[:IDENTIFIER, '@name']]

    %w(+ - * / % < > >= <= -> && ||).each do |operator|
      tokenizes "some identifier #{operator} bar", [
        [:IDENTIFIER, 'some identifier'],
        [operator, operator],
        [:IDENTIFIER, 'bar'],
      ]
    end
  end

  def test_double_operators
    %w(== != <= -> >=).each do |operator|
      tokenizes operator, [
        [operator, operator]
      ]
    end
  end

  def test_everything_else
    %w(> < + - * / ^ & { } [ ]).each do |symbol|
      tokenizes symbol, [[symbol, symbol]]
    end
  end
end
