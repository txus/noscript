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

class Empty
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
      self[:__name__] = "Object"
      self[:traits] = []
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
      to_a.each do |k, v|
        fn.call(self, k.to_s, v)
      end
    end

    noscript_def("puts") do |*args|
      puts(*args)
    end

    noscript_def("put") do |k, v|
      put(k, v)
    end

    noscript_def("get") do |slot|
      get(slot)
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
      elsif method = trait_implementation_of(name)
        method
      elsif proto = prototype
        proto.get(name)
      else
        Empty.new
      end
    end

    def trait_implementation_of(name)
      # Check for an explicit call, i.e. @Businessman run()
      explicit_method = self[:traits].map do |trait|
        explicit_name = name.to_s.split(trait[:__name__]).last.strip.to_sym
        if name != explicit_name && trait.key?(explicit_name)
          trait.get(explicit_name)
        else
          nil
        end
      end.compact.first
      return explicit_method if explicit_method

      # Otherwise, check for the normal trait chain
      matching = self[:traits].map do |trait|
        if trait.key?(name)
          trait.get(name)
        else
          nil
        end
      end.compact
      return false if matching.length == 0
      raise "Trait conflict: ##{name} is implemented by more than one trait." if matching.length > 1
      return matching.first
    end

    def put(name, object)
      self[name] = object
    end

    def has_property?(name)
      if result = key?(name)
        result
      elsif trait_implementation_of(name)
        true
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
  noscript_def("print") { print self; self }
  noscript_def("puts") { puts self; self }
end

class Array
  noscript_alias [:first, :last, :at, :<<, :length, :join]
  noscript_def("each") do |*args|
    fn = args.shift
    each do |element|
      fn.call(self, element)
    end
    self
  end
end

class Hash
  noscript_alias [:keys, :values, :length]
  noscript_def("each pair") do |*args|
    fn = args.shift
    each_pair do |k,v|
      fn.call(self, k, v)
    end
    self
  end
end
