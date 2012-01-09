require 'test_helper'

module Noscript
  class ParserWhiteSpaceAndCommentsTest < MiniTest::Unit::TestCase
    def setup
      @parser = Noscript::Parser.new
    end

    def test_parser_whitespace_and_comments
      number = @parser.parse_string("\n\n\n#Hello\n\n#ho\n3").body.expressions.first
      assert_equal 7, number.line
      assert_equal 3, number.value
    end

    def test_parser_inline_comments
      number = @parser.parse_string("\n\n\n#Hello\n\n#ho\n3 #whatever").body.expressions.first
      assert_equal 7, number.line
      assert_equal 3, number.value
    end
  end
end
