require 'rexpl'

module Noscript
  class BytecodeCompiler
    attr_reader :generator, :scope
    alias g generator
    alias s scope

    def initialize(parent=nil)
      @generator = Generator.new
      parent_scope = parent ? parent.scope : nil
      @scope = Scope.new(@generator, parent_scope)
    end

    def compile(ast, debugging=false)
      if debugging
        require 'pp'
        pp ast
      end

      ast = ast.body if ast.kind_of?(Rubinius::AST::EvalExpression)

      if ast.respond_to?(:filename) && ast.filename
        g.file = ast.filename
      else
        g.file = :"(noscript)"
      end

      g.set_line ast.line || 1

      ast.accept(self)

      debug if debugging
      g.ret

      finalize
    end

    def visit_Script(o)
      set_line(o)
      o.body.accept(self)
    end

    def visit_ArrayLiteral(o)
      set_line(o)
      o.body.each do |x|
        x.accept(self)
      end

      g.make_array o.body.size
    end

    def visit_Nodes(o)
      set_line(o)
      size = o.expressions.length
      o.expressions.each do |exp|
        size -= 1
        exp.accept(self)
        g.pop if size > 0
      end
    end

    def visit_FunctionLiteral(o)
      set_line(o)
      # Get a new compiler
      block = BytecodeCompiler.new(self)

      # Configures the new generator
      # TODO Move this to a method on the compiler
      block.generator.for_block = true
      block.generator.total_args = o.arguments.size
      block.generator.required_args = o.arguments.size
      block.generator.post_args = o.arguments.size
      block.generator.cast_for_multi_block_arg unless o.arguments.empty?
      block.generator.set_line o.line if o.line

      block.visit_arguments(o.arguments)
      o.body.accept(block)

      block.generator.ret

      g.push_const :Function

      # Invoke the create block instruction
      # with the generator of the block compiler
      g.create_block block.finalize
      g.send :new, 1
    end

    def visit_arguments(args)
      args.each_with_index do |a, i|
        g.shift_array
        s.set_local a
        g.pop
      end
      g.pop unless args.empty?
    end

    def visit_CallNode(o)
      meth = o.method.respond_to?(:name) ? o.method.name.to_sym : o.method.to_sym
      size = o.arguments.length + 1

      if o.receiver
        o.receiver.accept(self)
        g.dup_top
      else
        meth = :call
        visit_Identifier(o.method)
        g.push_self
      end

      o.arguments.each do |argument|
        argument.accept(self)
      end

      g.noscript_send meth, size
    end

    def visit_Identifier(o)
      set_line(o)

      if o.constant?
        g.push_runtime
        g.find_const o.name.to_sym
      elsif o.deref? # @foo equals to self.foo
        g.push_self
        g.push_literal o.name
        g.send :get, 1
        g.raise_if_empty NameError, "Object has no slot named #{o.name}"
      elsif o.self?
        g.push_self
      elsif s.slot_for(o.name)
        visit_LocalVariableAccess(o)
      else
        raise "CANT FIND #{o.name}"
      end
    end

    def visit_HashLiteral(o)
      set_line(o)

      count = o.array.size
      i = 0

      g.push_cpath_top
      g.find_const :Hash
      g.push count / 2
      g.send :new_from_literal, 1

      while i < count
        k = o.array[i]
        v = o.array[i + 1]

        g.dup
        k.accept(self)
        v.accept(self)
        g.send :[]=, 2
        g.pop

        i += 2
      end
    end

    def visit_LocalVariableAssignment(o)
      identifier = o.name
      if identifier.deref?
        g.push_self
      end

      name = identifier.name

      set_line(o)
      o.value.accept(self)

      if identifier.constant?
        s.set_const name
      elsif identifier.deref?
        g.push_literal name
        g.swap
        g.send :put, 2
      else
        s.set_local name
      end
    end

    AST::RubiniusNodes.each do |rbx|
      define_method("visit_#{rbx}") do |o|
        set_line(o)
        o.bytecode(g)
      end
    end

    def visit_StringLiteral(o)
      set_line(o)
      o.bytecode(g)
    end

    def visit_LocalVariableAccess(o)
      set_line(o)
      if s.variables.include?(o.name)
        s.push_variable o.name
      else
        raise NameError, "Undefined local variable #{o.name}"
      end
    end

    def visit_SlotGet(o)
      set_line(o)
      o.receiver.accept(self)
      g.push_literal o.name
      g.send :get, 1
      g.raise_if_empty NameError, "Object has no slot named #{o.name}"
    end

    def visit_SlotAssign(o)
      set_line(o)
      o.receiver.accept(self)
      g.push_literal o.name
      o.value.accept(self)
      g.send :put, 2
    end

    def visit_IfNode(o)
      set_line(o)
      done = g.new_label
      else_label = g.new_label

      o.condition.accept(self)
      g.gif else_label

      o.body.accept(self)
      g.goto done

      else_label.set!
      o.else_body.accept(self)

      g.set_line 0
      done.set!
    end

    def visit_WhileNode(o)
      set_line(o)
      brk = g.new_label
      repeat = g.new_label
      repeat.set!

      # Evaluate the condition and jump to the end if false
      o.condition.accept(self)
      g.gif brk

      # Otherwise, evaluate the body and jump to the start of the loop again.
      o.body.accept(self)
      g.pop
      g.goto repeat

      brk.set!
      g.push_nil
    end

    def finalize
      g.local_names = s.variables
      g.local_count = s.variables.size
      g.close
      g
    end

    def set_line(o)
      g.set_line o.line if o.line
    end

    def debug(gen = self.g)
      p '*****'
      ip = 0
      while instruction = gen.stream[ip]
        instruct = Rubinius::InstructionSet[instruction]
        ip += instruct.size
        puts instruct.name
      end
      p '**end**'
    end
  end
end
