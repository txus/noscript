module Noscriptable
  def __noscript_prototype__
    @__noscript_prototype__
  end

  def __noscript_prototype__=(proto)
    @__noscript_prototype__ = proto
  end

  def __noscript_slots__
    @__noscript_slots__ ||= begin
      slots = Rubinius::LookupTable.new
      slots[:__name__] = "Object"
      slots[:traits] = []
      slots
    end
  end

  def __noscript_get__(name)
    if __noscript_slots__.key?(name)
      __noscript_slots__[name]
    elsif self.methods.include?(:"noscript:#{name}")
      self.method(:"noscript:#{name}")
    elsif method = __noscript_trait_has__(name)
      method
    elsif proto = __noscript_prototype__
      proto.__noscript_get__(name)
    else
      Empty.new
    end
  end

  def __noscript_trait_has__(name)
    # Check for an explicit call, i.e. @Businessman run()
    explicit_method = __noscript_slots__[:traits].map do |trait|
      explicit_name = name.to_s.split(trait.__noscript_slots__[:__name__]).last.strip.to_sym
      if name != explicit_name && trait.__noscript_has_property__(explicit_name, false)
        trait.__noscript_get__(explicit_name)
      else
        nil
      end
    end.compact.first
    return explicit_method if explicit_method

    # Otherwise, check for the normal trait chain
    matching = __noscript_slots__[:traits].map do |trait|
      if trait.__noscript_has_property__(name, false)
        trait.__noscript_get__(name)
      else
        nil
      end
    end.compact
    return false if matching.length == 0
    raise "Trait conflict: ##{name} is implemented by more than one trait." if matching.length > 1
    return matching.first
  end

  def __noscript_has_property__(name, lookup=true)
    if result = __noscript_slots__.key?(name)
      result
    elsif lookup && __noscript_trait_has__(name)
      true
    elsif lookup && proto = __noscript_prototype__
      proto.__noscript_has_property__(name)
    else
      false
    end
  end

  def __noscript_put__(name, object)
    __noscript_slots__[name] = object
  end

  def method_missing(m, *args)
    function = m.to_s.split(":").last.to_sym
    if __noscript_has_property__(function)
      fn = __noscript_get__(function)
      return fn.call(*args) # First arg is this.
    end
    super
  end
end

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

class Class
  noscript_alias [:new]
  noscript_def 'def' do |name, implementation|
    define_method(name, &implementation)
  end
end

class Object
  include Noscriptable
  def noscript_send(name, *args)
    __send__ "noscript:#{send}", *args
  end

  noscript_def("clone") do |*args|
    obj = Object.new
    obj.__noscript_prototype__ = self
    if properties = args.first
      properties.keys.each do |k|
        obj.__noscript_put__(k.to_sym, properties[k])
      end
    end
    obj
  end

  noscript_def("each slot") do |*args|
    fn = args.shift
    __noscript_slots__.to_a.each do |k, v|
      fn.call(self, k.to_s, v)
    end
  end

  noscript_def("puts") do |*args|
    puts(*args)
  end

  noscript_def("get") do |slot|
    __noscript_get__(slot)
  end

  noscript_def("put") do |slot|
    __noscript_put__(slot)
  end

  noscript_def("ruby") do |*args|
    send *args
  end

  noscript_alias [:==, :"!="]
  noscript_alias [:include, :extend, :def]
  noscript_def("@!") { !self }

  noscript_alias :nil?
  noscript_alias :inspect
  noscript_def("puts") { |*args| send :puts, *args } # Because it's private

  noscript_def("respond to?") { |name| respond_to? "noscript:#{name}"}
end

class Empty
end

class Runtime
  Object = ::Object.new
  # class ObjectKind
  #   include Noscriptable
  #   noscript_def("clone") do |*args|
  #     obj = ObjectKind.new
  #     obj.__noscript_prototype__ = self
  #     if properties = args.first
  #       properties.keys.each do |k|
  #         obj.__noscript_put__(k.to_sym, properties[k])
  #       end
  #     end
  #     obj
  #   end

  #   noscript_def("each slot") do |*args|
  #     fn = args.shift
  #     __noscript_slots__.to_a.each do |k, v|
  #       fn.call(self, k.to_s, v)
  #     end
  #   end

  #   noscript_def("puts") do |*args|
  #     puts(*args)
  #   end

  #   noscript_def("put") do |k, v|
  #     __noscript_put__(k, v)
  #   end

  #   noscript_def("get") do |slot|
  #     __noscript_get__(slot)
  #   end
  # end
  # Object = ObjectKind.new
end

class Function
  attr_reader :executable
  def initialize(blk_env)
    @block_environment = blk_env
    @executable = blk_env.code
  end

  def call(this, *args)
    @executable.invoke(:anonymous, @executable.scope.module, this, args, nil)
  end

  def to_proc
    Proc.__from_block__(@block_environment)
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
  noscript_alias [:keys, :values, :length, :fetch]
  noscript_def("each pair") do |*args|
    fn = args.shift
    each_pair do |k,v|
      fn.call(self, k, v)
    end
    self
  end
end
