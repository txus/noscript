#--
# DO NOT MODIFY!!!!
# This file is automatically generated by rex 1.0.5
# from lexical definition file "lib/noscript/parser/noscript.rex".
#++

require 'racc/parser'
#
# noscript.rex
#
# Noscript Lexer
#
module Noscript
class Parser < Racc::Parser
  require 'strscan'

  class ScanError < StandardError ; end

  attr_reader   :lineno
  attr_reader   :filename
  attr_accessor :state

  def scan_setup(str)
    @ss = StringScanner.new(str)
    @lineno =  1
    @state  = nil
  end

  def action
    yield
  end

  def scan_str(str)
    scan_setup(str)
    do_parse
  end
  alias :scan :scan_str

  def load_file( filename )
    @filename = filename
    open(filename, "r") do |f|
      scan_setup(f.read)
    end
  end

  def scan_file( filename )
    load_file(filename)
    do_parse
  end


  def next_token
    return if @ss.eos?
    
    # skips empty actions
    until token = _next_token or @ss.eos?; end
    token
  end

  def _next_token
    text = @ss.peek(1)
    @lineno  +=  1  if text == "\n"
    token = case @state
    when nil
      case
      when (text = @ss.scan(/[\n]+[\s]*/))
         action { [:NEWLINE, text] }

      when (text = @ss.scan(/\d+/))
         action { [:DIGIT, text.to_i] }

      when (text = @ss.scan(/==/))
         action { [:EQUALS, text] }

      when (text = @ss.scan(/!=/))
         action { [:NEQUALS, text] }

      when (text = @ss.scan(/>=/))
         action { [:GTE_OP, text] }

      when (text = @ss.scan(/<=/))
         action { [:LTE_OP, text] }

      when (text = @ss.scan(/</))
         action { [:LT_OP, text] }

      when (text = @ss.scan(/>/))
         action { [:GT_OP, text] }

      when (text = @ss.scan(/true/))
         action { [:TRUE, text] }

      when (text = @ss.scan(/false/))
         action { [:FALSE, text] }

      when (text = @ss.scan(/nil/))
         action { [:NIL, text] }

      when (text = @ss.scan(/=/))
         action { [:ASSIGN, text] }

      when (text = @ss.scan(/,/))
         action { [:COMMA, text] }

      when (text = @ss.scan(/;/))
         action { [:SEMICOLON, text] }

      when (text = @ss.scan(/'[^']*'/))
         action { [:STRING, text[1..-2]] }

      when (text = @ss.scan(/def/))
         action { [:DEF, text] }

      when (text = @ss.scan(/\(/))
         action { [:LPAREN, text] }

      when (text = @ss.scan(/\)/))
         action { [:RPAREN, text] }

      when (text = @ss.scan(/end/))
         action { [:END, text] }

      when (text = @ss.scan(/if/))
         action { [:IF, text] }

      when (text = @ss.scan(/else/))
         action { [:ELSE, text] }

      when (text = @ss.scan(/\w[\s\w]*/))
         action { [:IDENTIFIER, text.strip] }

      when (text = @ss.scan(/\s/))
        ;

      when (text = @ss.scan(/./))
         action { [text, text] }

      else
        text = @ss.string[@ss.pos .. -1]
        raise  ScanError, "can not match: '" + text + "'"
      end  # if

    else
      raise  ScanError, "undefined state: '" + state.to_s + "'"
    end  # case state
    token
  end  # def _next_token

end # class
end
