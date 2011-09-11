gem 'minitest'
require 'minitest/unit'
require 'minitest/autorun'
require 'purdytest'

require 'noscript'

class MiniTest::Unit::TestCase
  def tokenizes(input, expected)
    lexer = Noscript::Parser.new
    lexer.scan_setup(input)
    tokens = []
    while token = lexer.next_token
      tokens << token
    end

    assert_equal expected, tokens
  end
end
