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
    /* nothing */     { result = Nodes.new([]); result.pos(filename, lineno) }
  | Expressions       { result = val[0] }
  ;

  # Any list of expressions, separated by line breaks.
  Expressions:
    Expression                        { result = Nodes.new(val); result.pos(filename, lineno) }
  | Expressions Terminator Expression { result = val[0] << val[2] }
  | Expressions Terminator            { result = val[0] }
  | Terminator                        { result = Nodes.new([]); result.pos(filename, lineno) }
  ;

  # All tokens that can terminate an expression.
  Terminator:
    NEWLINE
  | ";"
  ;

  # All types of expression in Noscript
  Expression:
    Literal
  | Call
  | Operator
  | Assign
  | If
  | While
  | '(' Expression ')'  { result = val[1] }
  ;

  # All hard-coded values
  Literal:
    INTEGER



  target : statements
         | /* none */ { 0 }

  assignment : identifier '.' identifier '=' statement { result = AST::Assignment.new(val[0], val[2], val[4]); result.pos(filename, lineno) }
             | identifier '=' statement { result = AST::Assignment.new(nil, val[0], val[2]); result.pos(filename, lineno) }

  fun_definition : '->' parameter_list end_of_statement statements END { result = AST::Function.new(val[1], val[3]); result.pos(filename, lineno) }

  message : identifier '.' identifier { result = AST::Message.new(val[0], val[2]); result.pos(filename, lineno) }
          | identifier '.' fun_call { result = AST::Message.new(val[0], val[2]); result.pos(filename, lineno) }
          | fun_call { result = AST::Message.new(nil, val[0]); result.pos(filename, lineno) }

  if_else : IF expression end_of_statement statements ELSE end_of_statement statements END { result = AST::IfNode.new(val[1], val[3], val[6]); result.pos(filename, lineno) }
          | IF expression end_of_statement statements END { result = AST::IfNode.new(val[1], val[3]); result.pos(filename, lineno) }

  while   : WHILE expression end_of_statement statements END { result = AST::WhileNode.new(val[1], val[3]); result.pos(filename, lineno) }

  identifier : IDENTIFIER { result = AST::Identifier.new(val[0]); result.pos(filename, lineno) }
             | DEREF { result = AST::Identifier.new(val[0], true); result.pos(filename, lineno) }

  integer : INTEGER { result = AST::Integer.new(val[0]); result.pos(filename, lineno) }
  string : STRING { result = AST::String.new(val[0]); result.pos(filename, lineno) }
  tuple : '{' tuple_elements '}' { result = AST::Tuple.new(val[1]); result.pos(filename, lineno) }
  array : '[' array_elements ']' { result = AST::Array.new(val[1]); result.pos(filename, lineno) }

  tuple_element : IDENTIFIER ':' argument { result = {val[0] => val[2]} }
                | end_of_statement tuple_element { result = val[1] }
                | tuple_element end_of_statement { result = val[0]}

  tuple_elements : { result = {} }
                 | tuple_element { result.merge!(val[0]) }
                 | tuple_elements ',' tuple_element { result.merge!(val[2]) }

  array_element : argument { result = val[0] }
                | end_of_statement array_element { result = val[1] }
                | array_element end_of_statement { result = val[0]}

  array_elements : { result = [] }
                 | array_element { result = [val[0]] }
                 | array_elements ',' array_element { result.push(val[2]) }

  literal : integer
          | string
          | tuple
          | array
          | fun_definition
          | boolean_literal
          | operation

  argument : identifier
           | literal
           | message

  argument_list : { result = [] }
                | argument  { result = [val[0]] }
                | argument_list ',' argument { result.push(val[2]) }

  parameter : identifier '=' argument { result = AST::DefaultParameter.new(val[0], val[2]); result.pos(filename, lineno)}
            | identifier

  parameter_list : { result = [] }
                 | parameter { result = [val[0]] }
                 | parameter_list ',' parameter { result.push(val[2]) }

  boolean_exp : op_member '==' op_member { result = AST::EqualityExpression.new(val[0], val[2]); result.pos(filename, lineno) }
              | op_member '!=' op_member { result = AST::InequalityExpression.new(val[0], val[2]); result.pos(filename, lineno) }
              | op_member '>' op_member { result = AST::GtExpression.new(val[0], val[2]); result.pos(filename, lineno) }
              | op_member '>=' op_member { result = AST::GteExpression.new(val[0], val[2]); result.pos(filename, lineno) }
              | op_member '<' op_member { result = AST::LtExpression.new(val[0], val[2]); result.pos(filename, lineno) }
              | op_member '<=' op_member { result = AST::LteExpression.new(val[0], val[2]); result.pos(filename, lineno) }
              | boolean_literal

  boolean_literal : TRUE { result = AST::True.new; result.pos(filename, lineno) }
                  | FALSE { result = AST::False.new; result.pos(filename, lineno) }
                  | NIL { result = AST::Nil.new; result.pos(filename, lineno) }

  expression : boolean_exp
             | message
             | '(' expression ')'

  statement : assignment
            | expression
            | message
            | literal
            | if_else
            | while
            | op_member
            | statement end_of_statement

  op_member : integer
            | operation
            | boolean_literal
            | identifier
            | message

  operation : op_member '+' op_member { result = AST::AddNode.new(val[0], val[2]); result.pos(filename, lineno) }
            | op_member '-' op_member { result = AST::SubtractNode.new(val[0], val[2]); result.pos(filename, lineno) }
            | op_member '*' op_member { result = AST::MultiplicationNode.new(val[0], val[2]); result.pos(filename, lineno) }
            | op_member '/' op_member { result = AST::DivisionNode.new(val[0], val[2]); result.pos(filename, lineno) }
            | '(' op_member ')' { result = val[1] }
            | '-' op_member =UMINUS { result = AST::UnaryMinus.new(val[1]); result.pos(filename, lineno) }

  statements : { result = AST::Nodes.new([]); result.pos(filename, lineno) }
             | statement { result = AST::Nodes.new([val[0]]); result.pos(filename, lineno) }
             | statements statement { result << val[1] }
             | NEWLINE statements { result = val[1] }

  end_of_statement : ';' | NEWLINE

  fun_call : identifier '(' argument_list ')'
             {
               result = AST::FunctionCall.new(val[0], val[2]); result.pos(filename, lineno)
             }


---- header ----
#
# generated by racc
#
require_relative 'lexer'

---- inner ----

include AST

---- footer ----