require_relative 'parser/parser'

module Noscript
  class Parser
    def initialize(*)
      @line = 1
      super
    end

    def parse_file(filename, log = false)
      parse_string(File.read(filename), filename, log)
    end

    def parse_string(input, file = '(eval)', log = false)
      @filename = file.to_sym
      scan_str(input)
    end
  end
end
