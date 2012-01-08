require 'rexpl'

module Noscript
  class Compiler < Rubinius::Compiler
    # module Noscriptify
    #   Rubinius::Compiler::Stage.extend self

    #   def new(compiler, *args, &block)
    #     if compiler.is_a? Noscript::Compiler and name =~ /^Rubinius::Compiler::([^:]+)$/
    #       const = Noscript::Compiler.const_get($1)
    #       return const.new(compiler, *args, &block) if const != self
    #     end
    #     super
    #   end
    # end

    # def self.noscript_compiled_name(file)
    #   if file.suffix? ".ns"
    #     file + "c"
    #   else
    #     file + ".compiled.nsc"
    #   end
    # end

    # def self.compile_fancy_file(file, output = nil, line = 1, print = false)
    #   compiler = new :fancy_file, :compiled_file

    #   parser = compiler.parser
    #   parser.root Noscript::AST::Script

    #   parser.input file, line

    #   if print
    #     parser.print
    #     printer = compiler.packager.print
    #     printer.bytecode = true
    #   end

    #   writer = compiler.writer
    #   writer.name = output ? output : noscript_compiled_name(file)

    #   begin
    #     compiler.run
    #   rescue Exception => e
    #     compiler_error "Error trying to compile noscript: #{file}", e
    #   end
    # end

    def self.compile_eval(string, variable_scope, file="(eval)", line=1)
      if ec = @eval_cache
        layout = variable_scope.local_layout
        if cm = ec.retrieve([string, layout, line])
          return cm
        end
      end

      compiler = new :noscript_eval, :compiled_method

      parser = compiler.parser
      parser.root Rubinius::AST::EvalExpression
      parser.input string, file, line

      compiler.generator.variable_scope = variable_scope

      cm = compiler.run

      cm.add_metadata :for_eval, true

      if ec and parser.should_cache?
        ec.set([string.dup, layout, line], cm)
      end

      return cm
    end

    # AST -> symbolic bytecode
    class Generator < Stage
      stage :bytecode
      next_stage Rubinius::Compiler::Encoder

      attr_accessor :variable_scope

      def initialize(compiler, last)
        super
        @variable_scope = nil
        compiler.generator = self
        @compiler = Noscript::BytecodeCompiler
      end

      def run
        compiler = @compiler.new
        @output = compiler.compile(@input)
        run_next
      end
    end

    class Parser < Rubinius::Compiler::Parser
      def initialize(compiler, last)
        super

        @compiler  = compiler
        @processor = Noscript::Parser
      end

      def create
        # TODO: we totally ignore @transforms
        @parser = @processor.new
        @parser
      end

      # def run
      #   @output = @root.new parse
      #   @output.file = @file
      #   run_next
      # end
    end

    class FileParser < Parser
      stage :noscript_file
      next_stage Noscript::Compiler::Generator

      def input(file, line = 1)
        @file = file
        @line = line
      end

      def parse
        create.parse_file
      end
    end

    class StringParser < Parser
      stage :noscript_string
      next_stage Noscript::Compiler::Generator

      def input(string, name = "(eval)", line = 1)
        @input = string
        @file = name
        @line = line
      end

      def parse
        create.parse_string(@input)
      end
    end

    class EvalParser < StringParser
      stage :noscript_eval
      next_stage Noscript::Compiler::Generator

      def should_cache?
        @output.should_cache?
      end
    end

    class Writer < Rubinius::Compiler::Writer
      def initialize(compiler, last)
        super
        @signature = Noscript::Signature
      end
    end
  end
end

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

    def visit_Nodes(o)
      set_line(o)
      o.expressions.each do |exp|
        exp.accept(self)
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

      if o.receiver
        o.receiver.accept(self)
      else
        meth = :call

        visit_Identifier(o.method, true)
      end

      o.arguments.each do |argument|
        argument.accept(self)
      end
      g.noscript_send meth, o.arguments.length
    end

    def visit_Identifier(o, for_method=false)
      set_line(o)

      if o.constant?
        g.push_const o.name.to_sym
        return
      end

      if s.slot_for(o.name)
        visit_LocalVariableAccess(o)
      else
        raise "Undefined identifier #{o.name}"
      end
    end

    def visit_LocalVariableAssignment(o)
      set_line(o)
      o.value.accept(self)
      s.set_local o.name
    end

    AST::RubiniusNodes.each do |rbx|
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

class Noscript::Compiler::Generator
  def initialize(compiler, last)
    super
    @variable_scope = nil
    compiler.generator = self
    @compiler = Noscript::BytecodeCompiler
  end

  def run
    compiler = @compiler.new
    @output = compiler.compile(@input)
    run_next
  end
end
