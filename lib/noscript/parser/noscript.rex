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

  ==            { [:EQUALS, text] }
  !=            { [:NEQUALS, text] }
  >=            { [:GTE_OP, text] }
  <=            { [:LTE_OP, text] }
  <             { [:LT_OP, text] }
  >             { [:GT_OP, text] }

  true          { [:TRUE, text] }
  false         { [:FALSE, text] }
  nil           { [:NIL, text] }

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
