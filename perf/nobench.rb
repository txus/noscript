class Array; def mean; inject(:+) / size.to_f; end; end
require 'benchmark'
require_relative '../lib/noscript'

TIMES = 10000

def benchmark(code)
  Noscript.eval_noscript(code)
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
      parser.parse_string(code, "(benchmark)")
    }
  end.mean * 1000
  puts "PARSER: #{parser_time - lexer_time}"

  # RUNTIME

  runtime = (0..TIMES).to_a.map do
    Benchmark.realtime {
      Noscript.eval_noscript(code)
    }
  end.mean * 1000

  puts "RUNTIME: #{runtime - parser_time - lexer_time}"
  puts "TOTAL: #{lexer_time + parser_time + runtime}"
rescue
  puts "ERROR"
end
