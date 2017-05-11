@testset "@fastcall" begin
    @test macroexpand(:(@fastcall f())) == :(f())
    @test macroexpand(:(@fastcall f(x))) == :(f(x))
    @test macroexpand(:(@fastcall f(x,y))) == :(f(x,y))

    # these are confusing
    @test_broken macroexpand(:(@fastcall f(a=1))) == :(GlobalRef(FastKeywords, Symbol("fastkw#f"))(GlobalRef(FastKeywords,:KW){:a}(1)))
    @test_broken macroexpand(:(@fastcall f(a=1,b=2))) == :(GlobalRef(FastKeywords, Symbol("fastkw#f"))(FastKeywords.KW{:a}(1), KW{:b}(2)))


end
