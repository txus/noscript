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

    def self.compiled_name(file)
      if file.suffix? ".ns"
        file + "c"
      else
        file + ".compiled.nsc"
      end
    end

    def self.compile_file(file, output = nil, line = 1, print = false)
      compiler = new :noscript_file, :compiled_file

      parser = compiler.parser
      parser.root Rubinius::AST::EvalExpression

      parser.input file, line

      if print
        parser.print
        printer = compiler.packager.print
        printer.bytecode = true
      end

      writer = compiler.writer
      writer.name = output ? output : compiled_name(file)

      begin
        compiler.run
      rescue Exception => e
        compiler_error "Error trying to compile noscript: #{file}", e
      end
    end

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
        create.parse_file(@file)
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
        create.parse_string(@input, @file)
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
