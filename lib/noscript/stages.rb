module Noscript
  class Stage
    # This stage takes a noscript filename and produces a ruby array
    # containing representation of the source.
    class NoscriptFile < Rubinius::Compiler::Stage
      stage :noscript_file
      next_stage NoscriptAST
      attr_reader :filename, :line
      attr_accessor :print

      def initialize(compiler, last)
        super
        @print = Compiler::Print.new
        compiler.parser = self
      end

      def input(filename, line = 1)
        @filename = filename
        @line = line
      end

      def run
        @output = File.read(@filename)
        run_next
      end
    end
  end
end
