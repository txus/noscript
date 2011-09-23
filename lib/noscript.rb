require_relative 'noscript/ast'
require_relative 'noscript/parser'

require_relative 'noscript/exceptions'
require_relative 'noscript/context'
require_relative 'noscript/object'
require_relative 'noscript/trait'
require_relative 'noscript/trait_list'

module Noscript
  def self.bootstrap
    # Generate top-level context
    ctx = Context.generate

    parser = Noscript::Parser.new

    # Compile files in /kernel
    Dir['kernel/*.ns'].each do |file|
      parser.scan_file(file).compile(ctx)
    end

    ctx
  end
end
