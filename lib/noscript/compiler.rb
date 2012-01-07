require 'rexpl'

module Noscript
  class Compiler
    attr_reader :generator, :scope
    alias g generator
    alias s scope

    def initialize(parent=nil)
      @generator = Generator.new
      parent_scope = parent ? parent.scope : nil
      @scope = Scope.new(@generator, parent_scope)
    end

    def compile(ast, debugging=false)
      ast = Noscript::Parser.new.parse(ast) unless ast.kind_of?(AST::Node)

      # require 'pp'
      # pp ast

      g.name = :call

      if ast.respond_to?(:filename) && ast.filename
        g.file = ast.filename
      else
        g.file = :"(noscript)"
      end

      g.set_line 1

      g.required_args = 0
      g.total_args = 0
      g.splat_index = nil

      ast.accept(self)

      debug if debugging

      g.ret

      finalize

      g.encode
      cm = g.package Rubinius::CompiledMethod
      puts cm.decode if $DEBUG

      code = Code.new
      ss = Rubinius::StaticScope.new Runtime
      Rubinius.attach_method g.name, cm, ss, code

      code
    end

    def visit_Script(o)
      set_line(o)
      o.body.accept(self)
    end

    def visit_Nodes(o)
      set_line(o)
      o.expressions.each do |exp|
        exp.accept(self)
      end
    end

    def visit_FunctionLiteral(o)
      set_line(o)
      # Get a new compiler
      block = Compiler.new(self)

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
      meth = nil
      if o.receiver
        meth = o.method.is_a?(String) ? o.method : o.method.name
        o.receiver.accept(self)
      else
        meth = :call
        visit_Identifier(o.method)
      end

      o.arguments.each do |argument|
        argument.accept(self)
      end

      g.noscript_send meth, o.arguments.length
    end

    def visit_Identifier(o)
      set_line(o)

      if o.constant?
        g.push_const o.name.to_sym
        return
      end

      if s.slot_for(o.name)
        visit_LocalVariableAccess(o)
      else
        g.push_nil
      end
    end

    def visit_LocalVariableAssignment(o)
      set_line(o)
      o.value.accept(self)
      s.set_local o.name
    end

    %w(StringLiteral FixnumLiteral ArrayLiteral HashLiteral TrueLiteral FalseLiteral NilLiteral).each do |rbx|

      define_method("visit_#{rbx}") do |o|
        set_line(o)
        o.bytecode(g)
      end
    end

    def visit_LocalVariableAccess(o)
      set_line(o)
      s.push_variable o.name
    end

    def visit_SlotGet(o)
      set_line(o)
      o.receiver.accept(self)
      g.push_literal o.name
      g.send :get, 1
    end

    def visit_SlotAssign(o)
      set_line(o)
      o.receiver.accept(self)
      g.push_literal o.name
      o.value.accept(self)
      g.send :put, 2
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

