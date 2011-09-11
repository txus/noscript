#
# noscript.rex
#
# Noscript Lexer
#
module Noscript
class Parser
rule
  [\n]+[\s]*    { [:NEWLINE, text] }
  \s
  \d+           { [:DIGIT, text.to_i] }
  =             { [:ASSIGN, text] }
  ,             { [:COMMA, text] }
  ;             { [:SEMICOLON, text] }
  '[^']*'       { [:STRING, text[1..-2]] }
  def           { [:DEF, text] }
  \(            { [:LPAREN, text] }
  \)            { [:RPAREN, text] }
  end           { [:END, text] }

  \w+           { [:IDENTIFIER, text] }
  .             { [text, text] }
end
end
