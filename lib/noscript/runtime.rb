class Module
  def noscript_alias(noscript_name, ruby_name=nil)
    Array(noscript_name).each do |noscript|
      ruby = ruby_name || noscript
      define_method("noscript:#{noscript}") do |*args|
        args.shift
        send ruby, *args
      end
    end
  end

  def noscript_def(name, &block)
    define_method("noscript:#{name}") do |*args|
      args.shift
      instance_exec(*args, &block)
    end
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
      @prototype = nil
      self[:name] = "Object"
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

    noscript_def("each slot") do |*args|
      fn = args.shift
      each do |name|
        fn.call(self, name.to_s, self[name])
      end
    end

    noscript_def("puts") do |*args|
      puts(*args)
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
      elsif self.methods.include?(:"noscript:#{name}")
        self.method(:"noscript:#{name}")
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

    def method_missing(m, *args)
      fun = m.to_s.split(":").last.to_sym
      if has_property?(fun)
        this = args.shift
        return get(fun).call(this, *args)
      end
      super
    end
  end
  Object = ObjectType.new
end

class Function
  def initialize(blk_env)
    @executable = blk_env.code
  end

  def call(this, *args)
    @executable.invoke(:anonymous, @executable.scope.module, this, args, nil)
  end

  define_method("noscript:call") do |*args|
    call(args.shift, *args)
  end
end

class Method
  define_method("noscript:call") do |*args|
    call(*args)
  end
end

class String
  noscript_def("starts with") do |pattern|
    self =~ /^#{pattern}/
  end
end

class Fixnum
  noscript_alias [:+, :-, :*, :/, :<, :>, :<=, :>=]
  noscript_def("-@") { -self }
end

class String
  noscript_alias [:+, :*, :length, :%]
  noscript_def("print") { puts self; self }
end

class Array
  noscript_alias [:first, :last, :at]
  noscript_def("each") do |*args|
    fn = args.shift
    each do |element|
      fn.call(self, element)
    end
    nil
  end
end

class Hash
  noscript_alias [:keys, :values, :length]
end
