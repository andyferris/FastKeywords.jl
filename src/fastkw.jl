"""
    @fastkw function f(x, y, ...; a=A, b=B, ...)
        ...
    end

Construct a fast, type-stable set of dispatches for `f` such that
"""
macro fastkw(expr)
    esc(expr)
end
