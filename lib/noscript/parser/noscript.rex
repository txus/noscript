#
# noscript.rex
#
# Noscript Lexer
#
class Noscript::Parser

macro
  BLANK         [\ ]

rule
  # Ignore comments and whitespace
  {BLANK}
  \#.*$

  # Newlines
  \n+           { [:NEWLINE, text] }

  # Literals
  \d+           { [:INTEGER, text.to_i] }
  \'[^']*\'     { [:STRING, text[1..-2]] }
  \"[^"]*\"     { [:STRING, text[1..-2]] }

  # Keywords
  end           { [:END, text] }
  if            { [:IF, text] }
  else          { [:ELSE, text] }
  while         { [:WHILE, text] }
  true          { [:TRUE, text] }
  false         { [:FALSE, text] }
  nil           { [:NIL, text] }

  # Longer operators
  ==            { [text, text] }
  !=            { [text, text] }
  >=            { [text, text] }
  <=            { [text, text] }
  ->            { [text, text] }
  &&            { [text, text] }
  \|\|            { [text, text] }

  # Identifiers
  \w[{BLANK}\w]*  { [:IDENTIFIER, text.strip] }
  @\w[{BLANK}\w]* { [:IDENTIFIER, text.strip] }

  # Catch all
  .             { [text, text] }

inner
  def run(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end

end
