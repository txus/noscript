class Array; def mean; inject(:+) / size.to_f; end; end
require 'benchmark'
require_relative '../lib/noscript'

TIMES = 10000

def benchmark(code)
  code.strip!

  Noscript::Parser.new.scan_str(code).compile(Noscript::Context.generate)
  # Do a first run to eliminate random GC effects

  # LEXER

  lexer = Noscript::Parser.new
  lexer_time = (0..TIMES).to_a.map do
    Benchmark.realtime {
      lexer.scan_setup(code)
      while token = lexer.next_token; end
    }
  end.mean * 1000
  puts "LEXER: #{lexer_time}"

  # PARSER

  parser = Noscript::Parser.new
  parser_time = (0..TIMES).to_a.map do
    Benchmark.realtime {
      parser.scan_str(code)
    }
  end.mean * 1000
  puts "PARSER: #{parser_time - lexer_time}"

  # RUNTIME

  parser = Noscript::Parser.new
  ast = parser.scan_str(code)
  runtime = (0..TIMES).to_a.map do
    Benchmark.realtime {
      ast.compile(Noscript::Context.generate)
    }
  end.mean * 1000

  puts "RUNTIME: #{runtime}"
  puts "TOTAL: #{lexer_time + parser_time + runtime}"
rescue
  puts "ERROR"
end
