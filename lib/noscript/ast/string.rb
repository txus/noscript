module Noscript
  module AST
    class String < Node
      attr_reader :value, :interpolated

      INTERPOLATION_REGEX = /\#{([^}]*)\}/

      def initialize(value, interpolated=false)
        @value = value
        @interpolated = !!@value.scan(INTERPOLATION_REGEX)
      end

      def compile(context)
        if @interpolated
          parser = Noscript::Parser.new
          interpolated_string = value.gsub(/\#{([^}]*)\}/) do
            parser.scan_str($1).compile(context).to_s
          end

          String.new(interpolated_string)
        else
          self
        end
      end

      def send(message)
        __send__ message.name
      end

      # Native methods must return an object that responds to #call.
      # TOOD: Refactor this into something nicer.
      define_method('starts with') do
        lambda {|context, *args|
          str = args.first
          value =~ /^#{str.value}/
        }
      end

      def to_s
        eval("\"#{value}\"")
      end
    end
  end
end
