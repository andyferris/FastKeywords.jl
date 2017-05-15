macro fastcall(expr)
    if !(expr isa Expr) || expr.head != :call || length(expr.args) < 1 || !(expr.args[1] isa Symbol)
        error("@fastcall macro expects an expression like f(x, y, ...; a=A, b=B, ...). Got $expr")
    end

    fname = expr.args[1]

    simplecall = true
    args = expr.args[2:end]
    for arg ∈ args
        if iskw(arg)
            simplecall = false
            break
        end
    end

    if simplecall
        return esc(expr)
    else
        newargs = make_ordered_kwlist(args)
        return Expr(:call, esc(fname), Expr(:tuple, newargs...))
    end
end

function make_ordered_kwlist(args)
    std_args = Vector{Any}()
    kw_args = Vector{Any}()
    kwlist = Vector{Symbol}()
    for arg ∈ args
        if iskw(arg)
            push!(kw_args, :(@kw($(esc(arg.args[1])) = $(esc(arg.args[2])))))
            push!(kwlist, arg.args[1])
        else
            push!(std_args, esc(arg))
        end
    end

    perm = sortperm(kwlist)
    kw_args = kw_args[perm]

    return (Expr(:tuple, KWSentinal(), kw_args...), std_args...)
end
