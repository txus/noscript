# noscript

Noscript is an object-oriented scripting language written in pure Ruby.

It's basically a way for me to learn about language design in a practical way.
In the future this language will run on the [Rubinius VM](http://rubini.us),
but for now I prefer to deal as much as possible with implementation detail,
learn as much as I can, and then go for the kick-ass Rubinius VM :)

Feel free to criticize and give advice, I'm happy to hear it!

# ACHTUNG

Noscript is currently under a heavy rewrite. If you want to check out what it
was before I started messing with everything, *check out the branch named "old"*.
The master branch is not to be considered even usable.

## Install (the old version)

Although for now it's in a **SUPER ALPHA** stage, you can try and run some
example scripts doing this:

    git clone git://github.com/txus/noscript
    git checkout old
    cd noscript
    bundle install
    ./bin/noscript examples/hello_world.ns
    ./bin/noscript examples/interop.ns
    ./bin/noscript examples/objects.ns
    ./bin/noscript examples/test_case.ns
    ./bin/noscript examples/traits.ns

## Copyright

Copyright (c) 2011 Josep M. Bach. See LICENSE for details.
