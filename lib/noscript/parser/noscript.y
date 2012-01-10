#
# Noscript grammar.
#

class Noscript::Parser

# Declare tokens produced by the lexer
token IF ELSE
token WHILE
token NEWLINE
token INTEGER
token STRING
token TRUE FALSE NIL
token IDENTIFIER
token END

prechigh
  nonassoc UMINUS
  left  '.'
  right '!'
  left  '*' '/'
  left  '+' '-'
  left  '>' '>=' '<' '<='
  left  '==' '!='
  left  '&&'
  left  '||'
  right '='
  left  ','
preclow

rule
  # The trunk of the AST.
  Root:
    /* nothing */     { result = Script.new(lineno, filename, Nodes.new(lineno, [])) }
  | Expressions       { result = Script.new(lineno, filename, val[0]) }
  ;

  # Any list of expressions, class or method body, separated by line breaks.
  Expressions:
    Expression                         { result = Nodes.new(lineno, val) }
  | Expressions Terminator Expression  { result = val[0] << val[2] }
    # To ignore trailing line breaks
  | Expressions Terminator             { result = val[0].is_a?(Nodes) ? val[0] : Nodes.new(lineno, val[0]) }
  | Terminator                         { result = Nodes.new(lineno, [NilLiteral.new(lineno)]) }
  |                                    { result = Nodes.new(lineno, [NilLiteral.new(lineno)]) }
  ;

  Newline:
    NEWLINE
  | NEWLINE Newline
  ;

  # All tokens that can terminate an expression
  Terminator:
    Newline
  | ";"
  ;

  # All types of expression in Noscript
  Expression:
    Literal
  | Call
  | SlotAssign
  | Operator
  | LocalAssign
  | If
  | While
  | SlotGet
  | Identifier
  | '(' Expression ')'  { result = val[1] }
  | Newline Expression  { result = val[1] }
  ;

  # All hard-coded values
  Literal:
    INTEGER { result = FixnumLiteral.new(lineno, val[0]) }
  | STRING  { result = StringLiteral.new(lineno, val[0]) }
  | Function{ result = val[0] }
  | Array   { result = val[0] }
  | Tuple   { result = val[0] }
  | TRUE    { result = TrueLiteral.new(lineno) }
  | FALSE   { result = FalseLiteral.new(lineno) }
  | NIL     { result = NilLiteral.new(lineno) }
  ;

  # Function
  #
  # -> a, b
  #   a + b
  # end
  Function:
    "->" ParamList Terminator
      Expressions
    END                           { result = FunctionLiteral.new(lineno, val[1], val[3]) }
  ;

  Array:
    LBracket ArrayList RBracket { result = ArrayLiteral.new(lineno, val[1]) }
  ;

  LBracket:
    '['
  | '[' Newline
  ;

  RBracket:
    ']'
  | Newline ']'
  ;

  ArrayList:
    /* nothing */                 { result = [] }
  | ArrayListElement                   { result = [val[0]] }
  | ArrayList "," ArrayListElement     { result = val[0] += [val[2]] }
  ;

  ArrayListElement:
    Expression                 { result = val[0] }
  | Newline Expression         { result = val[1] }
  | Expression Newline         { result = val[0] }
  ;

  Tuple:
    LBrace TupleList RBrace { result = HashLiteral.new(lineno, val[1].flatten) }
  ;

  TupleList:
    /* nothing */                 { result = [] }
  | TupleListElement                   { result = val[0] }
  | TupleList "," TupleListElement     { result = val[0] + val[2] }
  ;

  TupleListElement:
    TupleKey ":" Expression    { result = [StringLiteral.new(lineno, val[0].name), val[2]] }
  ;

  TupleKey:
    Identifier
  | Newline Identifier { result = val[1] }
  ;

  LBrace:
    '{'
  | '{' Newline
  ;

  RBrace:
    '}'
  | Newline '}'
  ;

  Identifier:
    IDENTIFIER { result = Identifier.new(lineno, val[0]) }
  ;

  LocalAssign:
    # foo = 123
    Identifier '=' Expression     { result = LocalVariableAssignment.new(lineno, val[0], val[2]) }
  ;

  SlotAssign:
    # receiver.slot = 123
    Expression '.' Identifier '=' Expression     { result = SlotAssign.new(lineno, val[0], val[2], val[4]) }
  ;

  # Get a slot from an object
  SlotGet:
    # receiver.slot
  | Expression '.' Identifier     { result = SlotGet.new(lineno, val[0], val[2]) }
  ;

  # Function call
  Call:
    # function(1, 2, 3)
    Identifier ArgListWithParens  { result = CallNode.new(lineno, nil, val[0], val[1]) }
    # receiver.function(1, 2, 3)
  | Expression '.' Identifier
      ArgListWithParens           { result = CallNode.new(lineno, val[0], val[2], val[3]) }
  ;

  ArgListWithParens:
    '(' ')'                             { result = [] }
  | '(' ArgList ')'                     { result = val[1] }
  ;

  ArgList:
    Expression                    { result = val }
  | ArgList "," Expression        { result = val[0] << val[2] }
  ;

  Operator:
    # Binary operators
    Expression '||' Expression    { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '&&' Expression    { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '==' Expression    { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '!=' Expression    { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '>' Expression     { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '>=' Expression    { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '<' Expression     { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '<=' Expression    { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
    # 1 + 2 => 1.+(2)
    #   1       +       2                           1       "+"      [2]
  | Expression '+' Expression     { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '-' Expression     { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '*' Expression     { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  | Expression '/' Expression     { result = CallNode.new(lineno, val[0], val[1], [val[2]]) }
  # Unary operators
  | '!' Expression                { result = CallNode.new(lineno, val[1], '!@', []) }
  | '-' Expression                { result = CallNode.new(lineno, val[1], '-@', []) }
  ;

  ParamList:
    /* nothing */                { result = [] }
  | Identifier                   { result = [val[0].name] }
  | ParamList "," Identifier     { result = val[0] << val[2].name }
  ;

  If:
    IF Expression Terminator
      Expressions
    END                                 { result = IfNode.new(lineno, val[1], val[3], nil) }
  | IF Expression Terminator
      Expressions
    ELSE Terminator
      Expressions
    END                                 { result = IfNode.new(lineno, val[1], val[3], val[6]) }
  ;

  While:
    WHILE Expression Terminator
      Expressions
    END                                 { result = WhileNode.new(lineno, val[1], val[3]) }
  ;

---- header ----
#
# generated by racc
#
require_relative 'lexer'

---- inner ----

include AST

def filename
  @filename
end

def on_error(t, val, vstack)
  raise ParseError, sprintf("\nparse error on value %s (%s) #{@filename}:#{@line}",
      val.inspect, token_to_str(t) || '?')
end

---- footer ----
