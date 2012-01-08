require_relative 'parser/parser'

module Noscript
  class Parser
    def initialize(*)
      super
      @line = 1
    end

    def parse_file(filename, log = false)
      parse_string(File.read(filename), filename, log)
    end

    def parse_string(input, file = '(eval)', log = false)
      scan_str(input.strip)
    end
  end
end
