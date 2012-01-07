# noscript

Noscript is an object-oriented, class-less programming language running on the
[Rubinius](http://rubini.us) Virtual Machine.

It takes design ideas from JavaScript, CoffeeScript, Self, IO and our beloved
Ruby.

## Installing

Noscript only runs on Rubinius, so you have to install it (if you use RVM,
[here](http://beginrescueend.com/interpreters/rbx/) is how you do it). Assuming
you have it installed:

    rvm use rbx
    gem install noscript

You can run your programs like this, pretty standard:

    noscript FILE

## Object Model

Noscript is [prototype-based](
http://en.wikipedia.org/wiki/Prototype-based_programming). Every object is a
clone of another object with a reference to it. An object is just a collection
of slots that can be assigned and retrieved. These slots can contain anything:
literals, functions and other objects.

`Object` is the master object to clone from, available from the main scope.

To create your first object, type this:

````noscript
greeter = Object.clone()
greeter.salute = name ->
  print("Hello #{name}!")
end
greeter.salute()
````

## Installing the old interpreter (AST-walker)

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
