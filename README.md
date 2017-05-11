# FastKeywords

[![Build Status](https://travis-ci.org/andyferris/FastKeywords.jl.svg?branch=master)](https://travis-ci.org/andyferris/FastKeywords.jl)

[![Coverage Status](https://coveralls.io/repos/andyferris/FastKeywords.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/andyferris/FastKeywords.jl?branch=master)

[![codecov.io](http://codecov.io/github/andyferris/FastKeywords.jl/coverage.svg?branch=master)](http://codecov.io/github/andyferris/FastKeywords.jl?branch=master)

The idea is this - we use macros to make keyword arguments type-stable (note that
it doesn't work yet):

```julia
@fastkw function f(x, y; a=1, b=2.0)
    x+y+a+b
end

f(3,4) == 3 + 4 + 1 + 2.0
@fastcall f(3, 4; a = pi) == 3 + 4 + pi + 2.0
```

This is a proof of concept of a design that can be applied at the lowering stage
of Julia compilation, which creates and invokes a simple dispatch system that
builds up a simple "named tuple" of (optional) keyword arguments.

The named tuple is created by a series of simple wrapper types `KW{name}(value)`,
which can be constructed via the `@kw` macro (e.g. `@kw(a=1)`). The final tuple
looks like `(@kw(a=b), @kw(b=2.0))` where the symbol names are sorted in-order
by the `@fastkw` and `@fastcall` macros for efficiency.
