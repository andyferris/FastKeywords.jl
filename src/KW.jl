struct KW{name, T}
    data::T

    KW{name, T}(x) where {name, T} = new{name::Symbol, T}(x)
end
KW{name}(x::T) where {name, T} = KW{name, T}(x)

name(::KW{n}) where {n} = n::Symbol
Base.get(kw::KW) = kw.data

Base.show(io::IO, kw::KW) = print(io, "@kw($(name(kw))=$(get(kw)))")

macro kw(expr)
    if !(expr isa Expr)
        error("@kw macro expects an expression like `name = value` or `(n1 = v1, n2 = v2, ...). Got $expr")
    end

    if iskw(expr)
        return :(KW{$(QuoteNode(expr.args[1]::Symbol))}($(esc(expr.args[2]))))
    elseif head.expr == :tuple
        return Expr(:tuple, map(ex -> :(@kw ex), expr.args))
    else
        error("@kw macro expects an expression like `name = value` or `(n1 = v1, n2 = v2, ...). Got $expr")
    end
end
