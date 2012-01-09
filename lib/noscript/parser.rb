require_relative 'parser/parser'

module Noscript
  class Parser
    def initialize(*)
      @line = 1
      super
    end

    def parse_file(filename, log = false)
      # @filename = file
      parse_string(File.read(filename), filename, log)
    end

    def parse_string(input, file = '(eval)', log = false)
      #@filename = file
      p input
      scan_str(input)
    end
  end
end
