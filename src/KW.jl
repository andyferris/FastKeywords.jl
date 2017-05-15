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

# A special kind of tuple type which holds all the values

struct KWSentinal
end

const KWTuple = Tuple{KWSentinal, Vararg{KW}}

@inline Base.getindex(kwt::KWTuple, name::Symbol) = kwt[Val{name}]
@inline function Base.getindex(kwt::KWTuple, ::Type{Val{name}}) where name
    _get(Val{name}, kwt...)
end

@inline _get(::Type{Val{name}}, ::KWSentinal, kws...) where {name} = _get(Val{name}, kws...)
@inline _get(::Type{Val{name}}, ::KW, kws...) where {name} = _get(Val{name}, kws...)
@inline _get(::Type{Val{name}}, kw::KW{name}, kws...) where {name} = get(kw)
@inline _get(::Type{Val{name}}) where {name} = error("Cannot find keyword with binding $name")
