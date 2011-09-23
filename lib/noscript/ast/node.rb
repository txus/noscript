module Noscript
  module AST
    class Node
      attr_reader :filename, :line

      def pos(filename, line)
        @filename = filename
        @line = line
      end

      def ==(other)
        instance_variables.all? do |ivar|
          instance_variable_get(ivar) == other.instance_variable_get(ivar)
        end
      end
    end
  end
end
