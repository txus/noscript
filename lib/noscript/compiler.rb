require 'rexpl'

module Noscript
  class BytecodeCompiler
    attr_reader :generator
    alias g generator

    def initialize(generator=nil)
      @generator = generator || Noscript::Generator.new
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

      line = ast.line || 1
      g.set_line line

      g.push_state Rubinius::AST::ClosedScope.new(line)

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

      g.push_const :Function

      state = g.state
      state.scope.nest_scope o

      blk_compiler = BytecodeCompiler.new(new_block_generator g, o.arguments)
      blk = blk_compiler.generator

      blk.push_state o
      blk.state.push_super state.super
      blk.state.push_eval state.eval

      blk.state.push_name blk.name

      o.arguments.accept(blk_compiler)
      blk.state.push_block
      o.body.accept(blk_compiler)
      blk.state.pop_block
      blk.ret
      blk_compiler.finalize

      g.create_block blk

      g.send :new, 1
    end

    def visit_FunctionArguments(o)
      args = o.arguments
      args.each_with_index do |a, i|
        g.shift_array
        local = g.state.scope.new_local(a)
        g.set_local local.slot
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

      name = o.name

      if o.constant?
        if o.ruby?
          g.push_cpath_top
        else
          g.push_runtime
          g.find_const name
        end
      elsif o.deref? # @foo equals to self.foo
        g.push_self
        g.push_literal name
        g.send :__noscript_get__, 1
        g.raise_if_empty NameError, "Object has no slot named #{name}"
      elsif o.self?
        g.push_self
      else
        AST::LocalVariableAccess.new(o.line, o).accept(self)
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
      identifier = o.identifier
      if identifier.deref?
        g.push_self
      end

      name = identifier.name

      set_line(o)
      o.value.accept(self)

      if identifier.constant?
        g.push_runtime
        g.swap
        g.push_literal name
        g.swap
        g.send :const_set, 2
      elsif identifier.deref?
        g.push_literal name
        g.swap
        g.send :__noscript_put__, 2
      else
        unless local = g.state.scope.search_local(name)
          local = g.state.scope.new_local(name)
        end
        g.set_local local.slot
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
      unless o.variable
        g.state.scope.assign_local_reference o
      end

      local = g.state.scope.search_local(o.name)
      local.get_bytecode(g)
    end

    def visit_SlotGet(o)
      set_line(o)
      o.receiver.accept(self)

      if o.receiver.constant? && o.name.constant? # Constant lookup like Rubinius.Compiler
        g.find_const o.name.name
      else
        g.push_literal o.name.name
        g.send :__noscript_get__, 1
      end

      g.raise_if_empty NameError, "Object has no slot named #{o.name}"
    end

    def visit_SlotAssign(o)
      set_line(o)
      o.receiver.accept(self)

      if o.receiver.constant? && AST::Identifier.new(1, o.name).constant? # Constant set like Rubinius.Compiler = something
        g.push_literal o.name
        o.value.accept(self)
        g.send :const_set, 2
      else
        g.push_literal o.name
        o.value.accept(self)
        g.send :__noscript_put__, 2
      end
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
      g.local_names = g.state.scope.local_names
      g.local_count = g.state.scope.local_count
      g.pop_state
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

    def new_block_generator(g, arguments)
      blk = g.class.new
      blk.name = g.state.name || :__block__
      blk.file = g.file
      blk.for_block = true

      blk.required_args = arguments.count
      blk.post_args = arguments.count
      blk.total_args = arguments.count
      blk.cast_for_multi_block_arg unless arguments.count.zero?

      blk
    end
  end
end
