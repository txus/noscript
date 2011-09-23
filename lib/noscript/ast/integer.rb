module Noscript
  module AST
    class Integer < Node
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def -@
        Integer.new(-to_i)
      end

      def +(num)
        Integer.new num.to_i + to_i
      end

      def -(num)
        Integer.new to_i - num.to_i
      end

      def *(num)
        Integer.new to_i * num.to_i
      end

      def /(num)
        Integer.new to_i / num.to_i
      end

      def compile(context)
        self
      end

      def to_s
        @value.to_s
      end

      def to_i
        @value.to_i
      end

      # Boolean comparisons

      def <(num)
        to_i < num.to_i
      end

      def >(num)
        to_i > num.to_i
      end

      def >=(num)
        to_i >= num.to_i
      end

      def <=(num)
        to_i <= num.to_i
      end

      def ==(num)
        to_i == num.to_i
      end

      def !=(num)
        to_i != num.to_i
      end
    end
  end
end
