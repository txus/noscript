module Noscript
  module AST
    class Boolean < Node
      def compile(context)
        self
      end
      def falsy?
        !truthy?
      end

      def ==(other)
        self.class == other.class
      end
    end

    class True < Boolean
      def truthy?
        true
      end
      def to_s
        "true"
      end
    end

    class False < Boolean
      def truthy?
        false
      end
      def to_s
        "false"
      end
    end

    class Nil < Boolean
      def truthy?
        false
      end
      def to_s
        "nil"
      end
    end
  end
end

class Object
  def truthy?
    true
  end
  def falsy?
    !truthy?
  end
end

class FalseClass
  def truthy?
    false
  end
end

class NilClass
  def truthy?
    false
  end
end
