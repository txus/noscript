# require 'rubygems'
# gem 'minitest'
# require 'minitest/unit'
require 'minitest/autorun'
# require 'minitest/spec'
# require 'purdytest'

require 'noscript'

class MiniTest::Unit::TestCase

  include Noscript
  include Noscript::AST

  def tokenizes(input, expected)
    lexer = Parser.new
    lexer.scan_setup(input)
    tokens = []
    while token = lexer.next_token
      tokens << token
    end

    assert_equal expected, tokens
  end

  def parses(input, &block)
    parser = Parser.new

    show_tokens(input) if ENV['DEBUG']

    ast = parser.parse_string(input, "(test)")
    block.call(ast.body.expressions)
  end

  private

  def show_tokens(input)
    lexer = Parser.new
    lexer.scan_setup(input.strip)
    tokens = []
    while token = lexer.next_token
      tokens << token
    end
    p tokens
  end

  def show_ast(input)
    parser = Parser.new
    ast = parser.scan_str(input.strip)
    p ast
  end
end
