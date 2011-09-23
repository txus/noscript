module Noscript
  module AST
    class Array < Node
      attr_reader :body

      def initialize(body)
        @body = body
      end

      def compile(context)
        Array.new(@body.map do |element|
          element.compile(context)
        end)
      end

      def send(message)
        __send__ message.name
      end

      define_method('push') do
        lambda {|context, *args|
          element = args.first
          @body.push(element.compile(context))
        }
      end

      define_method('each') do
        lambda { |context, fun|
          method = fun.compile(context)

          @body.each do |element|
            method.call(context, element)
          end
        }
      end
    end
  end
end
