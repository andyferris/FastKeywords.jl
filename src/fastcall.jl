macro fastcall(expr)
    if !(expr isa Expr) || expr.head != :call || length(expr.args) < 1 || !(expr.args[1] isa Symbol)
        error("@fastcall macro expects an expression like f(x, y, ...; a=A, b=B, ...). Got $expr")
    end

    oldname = expr.args[1]
    newname = Symbol("fastkw#$oldname") # TODO deal with namespaces

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
        return Expr(:call, newname, newargs...) # TODO excape newname?
    end
end

function make_ordered_kwlist(args)
    newargs = Vector{Any}()
    kwlist = Vector{Symbol}()
    for arg ∈ args
        if iskw(arg)
            push!(newargs, :(@kw($(esc(arg.args[1])) = $(esc(arg.args[2])))))
            push!(kwlist, arg.args[1])
        else
            push!(newargs, esc(arg))
        end
    end

    perm = sortperm(kwlist)
    newargs[(end-length(kwlist)+1):end] = newargs[(end-length(kwlist)+1):end][perm]
end
