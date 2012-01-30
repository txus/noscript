require 'rexpl'

module Noscript
  class BytecodeCompiler
    attr_reader :generator, :scope
    alias g generator
    alias s scope

    def initialize
      @generator = Generator.new
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

      g.push_state Rubinius::AST::ClosedScope.new(ast.line || 1)

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
      p "visit nodes #{o}"
      set_line(o)
      size = o.expressions.length
      o.expressions.each do |exp|
        size -= 1
        p "accepting #{exp}"
        exp.accept(self)
        g.pop if size > 0
      end
    end

    # def visit_FunctionLiteral(o)
    #   set_line(o)
    #   # Get a new compiler
    #   p "COMPILING #{o} with parent scope #{@scope}"
    #   block = BytecodeCompiler.new(@scope)

    #   # Configures the new generator
    #   # TODO Move this to a method on the compiler
    #   block.generator.for_block = true
    #   block.generator.total_args = o.arguments.size
    #   block.generator.required_args = o.arguments.size
    #   block.generator.post_args = o.arguments.size
    #   block.generator.cast_for_multi_block_arg unless o.arguments.empty?
    #   block.generator.set_line o.line if o.line

    #   # scope = Rubinius::AST::ClosedScope.new(o.line)
    #   # block.generator.push_state scope
    #   # block.generator.push_runtime
    #   # block.generator.add_scope

    #   block.visit_arguments(o.arguments)
    #   o.body.accept(block)

    #   block.generator.ret

    #   g.push_const :Function

    #   # Invoke the create block instruction
    #   # with the generator of the block compiler
    #   g.create_block block.finalize
    #   g.send :new, 1
    # end

    def visit_FunctionLiteral(o)
      g.push_const :Function

      state = g.state
      state.scope.nest_scope o

      args_len = o.arguments.arguments.args.size

      block = BytecodeCompiler.new
      block.generator.for_block = true
      block.generator.total_args = args_len
      block.generator.required_args = args_len
      block.generator.post_args = args_len
      block.generator.cast_for_multi_block_arg unless o.arguments.arguments.args.empty?
      block.generator.set_line o.line if o.line

      # blk = new_block_generator g, @arguments

      block.generator.push_state o
      block.generator.state.push_super state.super
      block.generator.state.push_eval state.eval

      block.generator.state.push_name block.generator.name

      # Push line info down.
      # pos(blk)

      o.arguments.bytecode(block.generator)

      block.generator.state.push_block
      block.generator.push_modifiers
      block.generator.break = nil
      block.generator.next = nil
      block.generator.redo = block.generator.new_label
      block.generator.redo.set!

      o.body.accept(block)

      block.generator.pop_modifiers
      block.generator.state.pop_block
      block.generator.ret
      block.generator.close

      block.generator.splat_index = o.arguments.splat_index
      block.generator.local_count = o.local_count
      block.generator.local_names = o.local_names


      g.create_block block.generator

      g.send :new, 1
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

      p g.state.scope.variables
      p g.state.scope.search_local(o.name)

      if o.constant?
        if o.ruby?
          g.push_cpath_top
        else
          g.push_runtime
          g.find_const o.name.to_sym
        end
      elsif o.deref? # @foo equals to self.foo
        g.push_self
        g.push_literal o.name
        g.send :__noscript_get__, 1
        g.raise_if_empty NameError, "Object has no slot named #{o.name}"
      elsif o.self?
        g.push_self


        g.set_local(g.state.scope.new_local(name).reference.slot)
      elsif g.state.scope.search_local(o.name)
        visit_LocalVariableAccess(o)
      else
        raise "BUG: CANT FIND #{o.name}"
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
        # s.set_local name
        p g.size
        g.set_local(g.state.scope.new_local(name).reference.slot)
        p g.size
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
      g.push_local g.state.scope.search_local(o.name).slot
    end

    def visit_SlotGet(o)
      set_line(o)
      o.receiver.accept(self)

      if o.receiver.constant? && o.name.constant? # Constant lookup like Rubinius.Compiler
        g.find_const o.name.name.to_sym
      else
        g.push_literal o.name.name.to_sym
        g.send :__noscript_get__, 1
      end

      g.raise_if_empty NameError, "Object has no slot named #{o.name}"
    end

    def visit_SlotAssign(o)
      set_line(o)
      o.receiver.accept(self)

      if o.receiver.constant? && AST::Identifier.new(1, o.name).constant? # Constant set like Rubinius.Compiler = something
        g.push_literal o.name.to_sym
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
      variables = p g.state.scope.variables
      g.local_names = variables.keys
      g.local_count = variables.keys.size
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
  end
end
