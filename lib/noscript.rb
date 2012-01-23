module Noscript
  require_relative 'noscript/version'
  require_relative 'noscript/ast'
  require_relative 'noscript/parser'
  require_relative 'noscript/stages'
  require_relative 'noscript/compiler'
  require_relative 'noscript/generator'
  require_relative 'noscript/scope'
  require_relative 'noscript/code'
  require_relative 'noscript/runtime'
  require_relative 'noscript/signature'
  require_relative 'noscript/code_loader'

  CodeLoader.load_paths << File.expand_path('../noscript', __FILE__)
  CodeLoader.run('kernel/traits')
  CodeLoader.run('kernel/test_case')

  def self.eval_noscript(code, *args)
    file, line, binding, instance = '(eval)', 1, Runtime::Object.send(:binding), Runtime::Object
    args.each do |arg|
      case arg
      when String   then file    = arg
      when Integer  then line    = arg
      when Binding  then binding = arg
      when Runtime::ObjectType  then instance = arg
      else raise ArgumentError
      end
    end

    cm       = Noscript::Compiler.compile_eval(code, binding.variables, file, line)
    cm.scope = Rubinius::StaticScope.new(Runtime)
    cm.name  = :__noscript__
    script   = Rubinius::CompiledMethod::Script.new(cm, file, true)
    be       = Rubinius::BlockEnvironment.new

    script.eval_binding = binding
    script.eval_source  = code
    cm.scope.script     = script

    be.under_context(binding.variables, cm)
    be.from_eval!
    be.call_on_instance(instance)
  end
end
