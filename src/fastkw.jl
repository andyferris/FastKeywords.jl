"""
    @fastkw function f(x, y, ...; a=A, b=B, ...)
        ...
    end

Construct a fast, type-stable set of dispatches for `f` such that
"""
macro fastkw(expr)
    (fname, kw_args, std_args, body) = function_def(expr)

    kw_names = map(kw -> esc(kw.args[1]), kw_args)
    kw_defaults = map(kw -> esc(kw.args[2]), kw_args)

    std_names = map(esc, std_args)
    std_defaults = nothing # TODO

    out_exprs = Vector{Any}()

    # First make a series of definitions for any standard arguments with default values
    # (TODO extract and support default values)

    # Next dispatch the final "standard" function to a keyword version.
    push!(out_exprs, quote
        function $(esc(fname))($(std_names)...)
            Base.@_propagate_inbounds_meta
            $(esc(fname))($(vcat((KWSentinal,), std_args)...))
        end
    end)

    # Now populate the keyword arguments one at a time
    kw_types = (KWSentinal, )
    for i = 1:length(kw_args)
        push!(out_exprs, quote
            function $(esc(fname))(kw::Tuple{$(kw_types...)}, $(std_names...))
                Base.@_propagate_inbounds_meta
                $(esc(fname))((kw..., KW{$(kw_names[i])}($(esc(kw_defaults[i])))), $(std_args...))
            end
        end)
        kw_types = (kw_types..., KW{kw_names[i].args[1]})
    end

    # Finally, when all keywords are populated, fill in local variables and given body
    kw_bindings = map(kw_names) do kw_name
        :(KW($(kw_name)) = kw[Val{$(kw_name)}])
    end

    metas = nothing # TODO: extract meta's from beginning of body and insert in correct place.
    main_body = esc(body)

    push!(out_exprs, quote
        function $(esc(fname))(kw::Tuple{$(kw_types...)}, $(std_args...))
            $metas
            $(Expr(:block, kw_bindings...))
            $main_body
        end
    end)


    # Currently don't yet support additional unnamed keyword arguments (TODO)
    # TODO: support :stagedfunction
    # TODO: support where clauses

    return Expr(:block, out_exprs...)
end

function_def(expr) = error("Expected a function definition")

function function_def(expr::Expr)
    if expr.head == :function || expr.head == :(=) || expr.head == :kw
        @assert length(expr.args) == 2
        body = expr.args[2]

        if (expr.args[1] isa Expr) && (expr.args[1].head == :call)
            fname = expr.args[1].args[1]
            args = expr.args[1].args[2:end]
            if (length(args) > 0) && (args[1] isa Expr) && (args[1].head == :parameters)
                kw_args = args[1].args
                std_args = args[2:end]
            else
                kwargs = Any[]
                std_args = args
            end
        else
            error("Expected a function definition")
        end

    else
        error("Expected a function definition")
    end
    return (fname, kw_args, std_args, body)
end
