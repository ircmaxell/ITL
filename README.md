# ITL
Some silly test programming language thingy

## The idea
Everything is a function. Literally everything.

## Syntax

The grammar is exceedingly simple. Just a few rules. Arguments are separated by spaces, and function calls are separated by spaces:

    foo 1 2
    
Calls the "foo" function with `1` and `2` as arguments.

Symbols are also supported, which are like identifiers except that they don't get resolved to the scope they exist in:

    :foo
    
This allows you to pass symbols into functions

    def :foo 1
    
This calls the `def` function with the string "foo" and the value "1"

The only other piece of important syntax is how you define a function:

    { |a b c| + a (+ b c) }
    
The part between the pipes (`|`) are the arguments, the the rest is the body of the function.

Functions can be immediately called:

    { |a| a } 1
    
Or they can be passed as arguments

    if a { || something } { || something else }
    
This means that even `if` is modeled as a function call (though this has some really weird semantic changes from most languages, for example there's no short-circuiting)

Returns are always implicit, meaning that a function returns the result of the last executed instruction.

## What's the point?

I have no idea. This was a dumb idea turned into a dumber implementation...
