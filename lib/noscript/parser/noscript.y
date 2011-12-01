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
token IDENTIFIER DEREF
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
    /* nothing */     { result = Nodes.new([]) }
  | Expressions       { result = val[0] }
  ;

  # Any list of expressions, class or method body, separated by line breaks.
  Expressions:
    Expression                         { result = Nodes.new(val) }
  | Expressions Terminator Expression  { result = val[0] << val[2] }
    # To ignore trailing line breaks
  | Expressions Terminator             { result = val[0] }
  | Terminator                         { result = Nodes.new([]) }
  ;

  # All tokens that can terminate an expression
  Terminator:
    NEWLINE
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
  ;

  # All hard-coded values
  Literal:
    INTEGER { result = IntegerNode.new(val[0]); result.pos(filename, lineno) }
  | STRING  { result = StringNode.new(val[0]); result.pos(filename, lineno) }
  | Function{ result = val[0] }
  | Array   { result = val[0] }
  | Tuple   { result = val[0] }
  | TRUE    { result = TrueNode.new; result.pos(filename, lineno) }
  | FALSE   { result = FalseNode.new; result.pos(filename, lineno) }
  | NIL     { result = NilNode.new; result.pos(filename, lineno) }
  ;

  # Function
  #
  # -> a, b
  #   a + b
  # end
  Function:
    "->" ParamList Terminator
      Expressions
    END                           { result = FunctionNode.new(val[1], val[3]); result.pos(filename, lineno) }
  ;

  Array:
    LBracket ArrayList RBracket { result = ArrayNode.new(val[1]); result.pos(filename, lineno)}
  ;

  LBracket:
    '['
  | '[' NEWLINE
  ;

  RBracket:
    ']'
  | NEWLINE ']'
  ;

  ArrayList:
    /* nothing */                 { result = [] }
  | ArrayListElement                   { result = [val[0]] }
  | ArrayList "," ArrayListElement     { result = val[0] += [val[2]] }
  ;

  ArrayListElement:
    Expression                 { result = val[0] }
  | NEWLINE Expression         { result = val[1] }
  | Expression NEWLINE         { result = val[0] }
  ;

  Tuple:
    LBrace TupleList RBrace { result = TupleNode.new(val[1]); result.pos(filename, lineno)}
  ;

  TupleList:
    /* nothing */                 { result = {} }
  | TupleListElement                   { result = val[0] }
  | TupleList "," TupleListElement     { result = val[0].merge!(val[2]) }
  ;

  TupleListElement:
    NEWLINE IDENTIFIER ":" Expression { result = { val[1] => val[3] } }
  ;

  LBrace:
    '{'
  | '{' NEWLINE
  ;

  RBrace:
    '}'
  | NEWLINE '}'
  ;

  Identifier:
    IDENTIFIER
  ;

  LocalAssign:
    # foo = 123
    IDENTIFIER '=' Expression     { result = LocalAssignNode.new(val[0], val[2]); result.pos(filename, lineno) }
  ;

  SlotAssign:
    # receiver.slot = 123
    Expression '.' IDENTIFIER '=' Expression     { result = SlotAssignNode.new(val[0], val[2], val[4]); result.pos(filename, lineno) }
  ;

  # Get a slot from an object
  SlotGet:
    # receiver.slot
  | Expression '.' IDENTIFIER     { result = SlotGetNode.new(val[0], val[2]); result.pos(filename, lineno) }
  ;

  # Function call
  Call:
    # function(1, 2, 3)
    IDENTIFIER ArgListWithParens  { result = CallNode.new(nil, val[0], val[1]); result.pos(filename, lineno) }
    # receiver.function(1, 2, 3)
  | Expression '.' IDENTIFIER
      ArgListWithParens           { result = CallNode.new(val[0], val[2], val[3]); result.pos(filename, lineno) }
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
    Expression '||' Expression    { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno) }
  | Expression '&&' Expression    { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno) }
  | Expression '==' Expression    { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno) }
  | Expression '!=' Expression    { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno) }
  | Expression '>' Expression     { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno) }
  | Expression '>=' Expression    { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno) }
  | Expression '<' Expression     { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno) }
  | Expression '<=' Expression    { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno) }
    # 1 + 2 => 1.+(2)
    #   1       +       2                           1       "+"      [2]
  | Expression '+' Expression     { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno)}
  | Expression '-' Expression     { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno)}
  | Expression '*' Expression     { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno)}
  | Expression '/' Expression     { result = CallNode.new(val[0], val[1], [val[2]]); result.pos(filename, lineno)}
  # Unary operators
  | '!' Expression                { result = CallNode.new(val[1], val[0], []); result.pos(filename, lineno) }
  ;

  ParamList:
    /* nothing */                { result = [] }
  | Parameter                    { result = val }
  | ParamList "," Parameter      { result = val[0] << val[2] }
  ;

  Parameter:
    IDENTIFIER '=' Expression { result = ParameterNode.new(val[0], val[2]); result.pos(filename, lineno)}
  | IDENTIFIER                { result = ParameterNode.new(val[0]); result.pos(filename, lineno) }
  ;

  If:
    IF Expression Terminator
      Expressions
    END                                 { result = IfNode.new(val[1], val[3], nil); result.pos(filename, lineno) }
  | IF Expression Terminator
      Expressions
    ELSE Terminator
      Expressions
    END                                 { result = IfNode.new(val[1], val[3], val[6]); result.pos(filename, lineno) }
  ;

  While:
    WHILE Expression Terminator
      Expressions
    END                                 { result = WhileNode.new(val[1], val[3]); result.pos(filename, lineno) }
  ;

---- header ----
#
# generated by racc
#
require_relative 'lexer'

---- inner ----

include AST

---- footer ----
