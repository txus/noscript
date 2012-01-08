class Module
  def noscript_alias(noscript_name, ruby_name=nil)
    Array(noscript_name).each do |noscript|
      ruby = ruby_name || noscript
      alias_method "noscript:#{noscript}", ruby
    end
  end

  def noscript_def(name, &block)
    define_method("noscript:#{name}", &block)
  end
end

class Object
  def noscript_send(name, *args)
    __send__ "noscript:#{send}", *args
  end

  noscript_alias [:==, :"!="]
  noscript_def("@!") { !self }

  noscript_alias :nil?
  noscript_alias :inspect
  noscript_def("puts") { |*args| send :puts, *args } # Because it's private

  noscript_def("respond to?") { |name| respond_to? "noscript:#{name}"}
end

class Runtime
  # Object protocol:
  #
  # get(name<Symbol>)        => object
  # put(name<Symbol>, object<Object>)
  #
  class ObjectType < Rubinius::LookupTable
    attr_accessor :prototype

    def initialize
      @prototype = Runtime::Object
    end

    noscript_def("clone") do |*args|
      obj = ObjectType.new
      obj.prototype = self
      if properties = args.first
        properties.keys.each do |k|
          obj.put(k.to_sym, properties[k])
        end
      end
      obj
    end

    # def function(name, block=name)
    #   if block.is_a?(Symbol)
    #     block = method(block).executable
    #   else
    #     block = block.code
    #   end

    #   self[name] = Function.new(name, block)
    # end

    def get(name)
      if self.key?(name)
        self[name]
      elsif proto = prototype
        proto.get(name)
      else
        nil
      end
    end

    def put(name, object)
      self[name] = object
    end

    def has_property?(name)
      if result = key?(name)
        result
      elsif proto = prototype
        proto.has_property?(name)
      else
        false
      end
    end
  end
  Object = ObjectType.new
end

class Function
  def initialize(blk_env)
    @executable = blk_env.code
  end

  noscript_def("call") do |*args|
    @executable.invoke(:anonymous, @executable.scope.module, Object.new, args, nil)
  end
end
class Fixnum
  noscript_alias [:+, :-, :*, :/, :<, :>, :<=, :>=]
  noscript_def("@-") { -self }
end

class Array
  noscript_alias [:first, :last, :at]
end

class Hash
  noscript_alias [:keys, :values, :length]
end
