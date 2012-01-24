# noscript

Noscript is an object-oriented, class-less programming language running on the
[Rubinius](http://rubini.us) Virtual Machine.

It takes design ideas from JavaScript, CoffeeScript, Self, IO and our beloved
Ruby.

## Installing

Noscript only runs on Rubinius, so you have to install it (if you use RVM,
[here](http://beginrescueend.com/interpreters/rbx/) is how you do it). Assuming
you have it installed:

    rvm use rbx-head
    git clone git://github.com/txus/noscript.git
    cd noscript

You can run your programs like this, pretty standard:

    ./bin/noscript examples/objects.ns

Or execute arbitrary code:

    ./bin/noscript -e "123.inspect().print()"

Use the `-A` and `-B` to show the AST representation and the generated Rubinius
bytecode if you want. Fun! :)

## Object Model

Noscript is [prototype-based](
http://en.wikipedia.org/wiki/Prototype-based_programming). Every object is a
clone of another object with a reference to it. An object is just a collection
of slots that can be assigned and retrieved. These slots can contain anything:
literals, functions and other objects.

As a difference with most languages, identifiers may contain whitespace. So
`foo`, `each pair` and `do something awesome` are all valid identifiers for
local variables, object attributes or method names. Due to this, function
invocations or method calls must have parens: `do something awesome` returns
a function, whereas `do something awesome()` calls it. Just like JavaScript.

`Object` is the master object to clone from, available from the main scope.

To create your first object, type this:

````noscript
greeter = Object.clone()
greeter.salute = -> name
  ("Hello %s!" % name).puts()
end
greeter.salute()
````

### Basic data types

* `[1, 2, 3]`: Arrays. Iterable through `#each`.
* `{a: 3, b: 9}`: Tuples. Iterable through `#each pair`.
* `1`: Fixnums. Duh.
* `'1'`: Strings. You can format them: `'Hello %s' % 'world'`.
* `-> arg1, argN; foo(); end`: Function literals.

### Behavior reusability through Traits

Traits are like Ruby modules in the sense that they can be used to define
composable units of behavior, but they are not included hierarchically. They
are truly composable, meaning that are pieces that *must* either fit
perfectly or the host object must provide a way for them to do it, normally
resolving conflicts by explicitly redefining the conflicting methods.

Create your first trait like this:

````noscript
Runnable = Trait.build("Runnable", {
  run: ->
    "Running!".puts()
  end
})

Serious = Trait.build("Serious", {
  run: ->
    "Running a serious business.".puts()
  end
})

person = Object.clone()
person.age = 20
person.uses(Runnable)

# If we did this now, Noscript would raise a trait conflict error, because
# person cannot have two traits with methods with the same names:
#
# person.uses(Serious)
#
# Instead we have to resolve the conflict defining the #run method on the host.

person.run = ->
  if @age > 30
    @Serious run()
  else
    @Runnable run()
  end
end

person.uses(Serious)

person.run()
# => Outputs "Running!"
person.age = 35
person.run()
# => Outputs "Running a serious business."
````

To read more about how traits work, read `examples/traits.ns`.

# Installing the old interpreter (AST-walker)

Before running on the Rubinius VM, Noscript was prototyped as a simple
AST-walker interpreter written in pure Ruby, without any Rubinius-specific
code.

If you want to check out what it was before I started the rewrite, *check out
the branch named "old"*.

The old branch is far from usable, but it's a nice example to play with.

    git clone git://github.com/txus/noscript
    git checkout old
    cd noscript
    bundle install
    ./bin/noscript examples/hello_world.ns
    ./bin/noscript examples/interop.ns
    ./bin/noscript examples/objects.ns
    ./bin/noscript examples/test_case.ns
    ./bin/noscript examples/traits.ns

## Who's this

This was made by [Josep M. Bach (Txus)](http://txustice.me) under the MIT
license. I'm [@txustice](http://twitter.com/txustice) on twitter (where you
should probably follow me!).
