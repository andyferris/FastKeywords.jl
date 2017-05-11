module FastKeywords

iskw(ex) = false
iskw(ex::Expr) = (ex.head == :(=) || ex.head == :kw) && length(ex.args) == 2 && (ex.args[1] isa Symbol)

include("KW.jl")
include("fastcall.jl")
include("fastkw.jl")

export @kw, @fastkw, @fastcall

end # module
