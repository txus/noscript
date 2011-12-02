module Noscript
  class JavascriptGenerator
    def initialize
      @code   = []
      @locals = []
    end

    def compile_all(nodes)
      nodes.each do |node|
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
      @locals.any?{|l| l == name}
    end

    def is_operator?(method)
      %(+ - * / == != > < >= <=).include?(method)
    end

    def integer_literal(value)
      emit value.to_s
    end

    def string_literal(value)
      emit value.to_s
    end

    def array_literal(value)
      emit "["
      value.each do |element|
        element.compile(self)
      end
      emit "]"
    end

    def tuple_literal(value)
      emit "{"
      value.each_pair do |k, v|
        k.compile(self)
        emit ": "
        v.compile(self)
      end
      emit "}"
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
      pop
      emit ") {\n"
      compile_all(body.nodes)
      emit "}"
    end

    def identifier(name)
      emit name
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
      emit method
      emit "("
      arguments.each do |argument|
        argument.compile(self)
        emit ", "
      end
      pop
      emit ")"
    end

    def set_local(name, value)
      @locals << name.name unless has_local?(name.name)
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
      body.compile(self)
      emit "}"
      if else_body
        emit "}"
        emit " else {\n"
        else_body.compile(self)
        emit "}"
      end
    end

    def while(condition, body)
      emit "while ("
      condition.compile(self)
      emit ") {"
      body.compile(self)
      emit "}"
    end

    def assemble
      @code.unshift "var #{@locals.join(', ')};"
      @code.join.split(";").join(";\n") << ";"
    end
  end
end
