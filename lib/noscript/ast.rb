require_relative 'scope'

module Noscript
  module AST
    RubiniusNodes = [
      :Node, :FixnumLiteral,
      :TrueLiteral, :FalseLiteral, :NilLiteral, :EvalExpression,
      :ClosedScope,
    ]
    RubiniusNodes.each { |n| const_set(n, Rubinius::AST.const_get(n)) }
  end
  module Visitable
    def accept(visitor)
      name = self.class.name.split("::").last
      visitor.send "visit_#{name}", self
    end
  end
end

Noscript::AST::Node.send :include, Noscript::Visitable

module Noscript
  module AST
    class Script < Node
      attr_reader :body, :filename
      attr_accessor :variable_scope

      def initialize(line, filename, body)
        super(line)
        body = Nodes.new(line, body) unless body.is_a?(Nodes)
        @filename = filename
        @body = body
      end
    end

    class Nodes < Node
      attr_reader :expressions

      def initialize(line, expressions)
        super(line)
        @expressions = expressions
      end

      def <<(exp)
        @expressions << exp
      end

      def empty?
        @expressions.empty?
      end
    end

    class FunctionLiteral < Node
      include Scope
      attr_reader :arguments, :body

      def initialize(line, arguments, body)
        @line = line
        @arguments = FunctionArguments.new(line, arguments)
        @body = body
      end
    end

    class FunctionArguments < Node
      attr_reader :arguments
      def initialize(line, arguments)
        @line = line
        @arguments = arguments
      end

      def count
        @arguments.count
      end
    end

    class StringLiteral < Rubinius::AST::StringLiteral
      def initialize(line, str)
        super(line, unescape_chars(str.to_s))
      end

      # Weird hack. Whoa.
      def unescape_chars(str)
        str.gsub("\\r", "\r").gsub("\\t", "\t").gsub("\\n", "\n").gsub("\\v", "\v").gsub("\\b", "\b").gsub("\\e", "\e").
          gsub("\\f", "\f").gsub("\\a", "\a").gsub("\\\\", "\\").gsub("\\?", "\?").gsub("\\'", "\'").gsub('\\"', '\"').gsub("\\\"", "\"")
      end
    end

    class ArrayLiteral < Node
      attr_accessor :body

      def initialize(line, array)
        @line = line
        @body = array
      end
    end

    # Node of a method call or local variable access, can take any of these forms:
    #
    #   method # this form can also be a local variable
    #   method(argument1, argument2)
    #   receiver.method
    #   receiver.method(argument1, argument2)
    #
    class CallNode < Node
      attr_reader :receiver, :method, :arguments

      def initialize(line, receiver, method, arguments)
        super(line)
        @receiver  = receiver
        @method    = method
        @arguments = arguments
      end
    end

    class Identifier < Node
      attr_reader :name

      def initialize(line, name)
        super(line)
        @constant = false
        @deref = false
        @self = (name == 'self')

        @name = name.to_sym

        if name.to_s[0] =~ /[A-Z]/
          @constant = true
        elsif name.to_s[0] == '@'
          @deref = true
          @name = name[1..-1].to_sym
        end
      end

      def constant?
        @constant
      end

      def ruby?
        @name == :Ruby
      end

      def deref?
        @deref
      end

      def self?
        @self
      end
    end

    class HashLiteral < Node
      attr_reader :array

      def initialize(line, array)
        super(line)
        @array = array
      end
    end

    class LocalVariableAccess < Node
      attr_reader :name, :identifier
      attr_accessor :variable

      def initialize(line, identifier)
        super(line)
        @identifier = identifier.is_a?(Identifier) ? identifier : Identifier.new(line, identifier)
        @name = @identifier.name
        @variable = nil
      end
    end

    class LocalVariableAssignment < Node
      attr_reader :identifier, :value, :name
      attr_accessor :variable
      def initialize(line, identifier, value)
        super(line)
        @identifier = identifier.is_a?(Identifier) ? identifier : Identifier.new(line, identifier)
        @name = @identifier.name
        @value = value
        @variable = nil
      end
    end

    class SlotAssign < Node
      attr_reader :receiver, :name, :value
      def initialize(line, receiver, name, value)
        super(line)
        @receiver = receiver
        @name     = name.name.to_sym
        @value    = value
      end
    end

    class SlotGet < Node
      attr_reader :receiver, :name
      def initialize(line, receiver, name)
        super(line)
        @receiver = receiver
        @name     = name
      end

      def constant?
        @name.constant?
      end
    end

    class IfNode < Node
      attr_reader :condition, :body, :else_body
      def initialize(line, condition, body, else_body=nil)
        super(line)
        @condition = condition
        @body      = body.expressions.any? ? body : NilLiteral.new(line)
        @else_body = else_body || NilLiteral.new(line)
      end
    end

    class WhileNode < Node
      attr_reader :condition, :body
      def initialize(line, condition, body)
        super(line)
        @condition = condition
        @body      = body
      end
    end
  end
end
