#
# noscript.rex
#
# Noscript Lexer
#
module Noscript
class Parser
macro
  BLANK         [\ ]
rule
  [\n]+[\s]*    { [:NEWLINE, text] }
  \d+           { [:DIGIT, text.to_i] }

  ==            { [:EQUALS, text] }
  !=            { [:NEQUALS, text] }
  >=            { [:GTE_OP, text] }
  <=            { [:LTE_OP, text] }
  <             { [:LT_OP, text] }
  ->            { [:FUN, text] }
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
  if            { [:IF, text] }
  else          { [:ELSE, text] }
  while         { [:WHILE, text] }

  \w[{BLANK}\w]* { [:IDENTIFIER, text.strip] }

  \s
  .             { [text, text] }
end
end
