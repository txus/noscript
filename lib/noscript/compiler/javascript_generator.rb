module Noscript
  class JavascriptGenerator
    def initialize
      @code   = []
      @locals = []
    end

    def compile_all(nodes, indent=0)
      nodes.each do |node|
        emit " " * indent
        node.compile(self)
        emit ";"
      end
    end

    def emit(code)
      @code << code
    end

    def pop
      @code.pop
    end

    def has_local?(name)
      @locals.any?{|l| l == name }
    end

    def is_operator?(method)
      name = method.is_a?(String) ? method : method.name
      %(+ - * / == != > < >= <=).include?(name)
    end

    def integer_literal(value)
      emit value.to_s
    end

    def string_literal(value)
      emit '"'
      emit value.to_s
      emit '"'
    end

    def array_literal(value)
      emit "["
      value.each do |element|
        element.compile(self)
      end
      emit "]"
    end

    def tuple_literal(value)
      emit "{\n  "
      value.each_pair do |k, v|
        emit "  "
        k.compile(self)
        emit ": "
        v.compile(self)
        emit",\n  "
      end
      pop
      emit "\n  }"
    end

    def function_literal(params, body)
      emit "function("
      params.each do |param|
        if param.default_value
          param.name.compile(self)
        else
          param.name.compile(self)
        end
        emit ", "
      end
      pop if params.any?
      emit ") {\n"
      compile_all(body.nodes, 2)
      emit "}"
    end

    def identifier(name)
      if name =~ /^@/
        emit "this."
        name = name[1..-1]
      end
      emit name.gsub(" ", "-")
    end

    def true_literal
      emit "true"
    end

    def false_literal
      emit "false"
    end

    def nil_literal
      emit "undefined"
    end

    def call(receiver, method, arguments)
      # Optimization for ==, >, <...
      if receiver && is_operator?(method) && arguments.length == 1
        receiver.compile(self)
        emit " "
        emit method
        emit " "
        arguments.first.compile(self)
        return
      end

      if receiver
        receiver.compile(self)
        emit "."
      end

      if method.is_a?(String)
        emit method
      else
        method.compile(self)
      end

      emit "("
      arguments.each do |argument|
        argument.compile(self)
        emit ", "
      end
      pop if arguments.any?
      emit ")"
    end

    def set_local(name, value)
      local_name = if name.name =~ /^@/
        name.name[1..-1]
      else
        name.name
      end
      @locals << local_name unless has_local?(local_name)
      name.compile(self)
      emit " = "
      value.compile(self)
    end

    def assign_slot(receiver, slot, value)
      receiver.compile(self)
      emit '.'
      slot.compile(self)
      emit ' = '
      value.compile(self)
    end

    def get_slot(receiver, name)
      receiver.compile(self)
      emit "."
      name.compile(self)
    end

    def if(condition, body, else_body)
      emit "if ("
      condition.compile(self)
      emit ") {\n"
      compile_all(body.nodes, 2)
      emit "}"
      if else_body
        emit " else {\n"
        compile_all(body.nodes, 2)
        emit "}"
      end
    end

    def while(condition, body)
      emit "while ("
      condition.compile(self)
      emit ") {\n"
      compile_all(body.nodes, 2)
      emit "}"
    end

    def assemble
      @code.unshift "var #{@locals.map{|l| l.gsub(" ", "-")}.join(', ')};"
      @code.join.split(";").join(";\n") << ";"
    end
  end
end
