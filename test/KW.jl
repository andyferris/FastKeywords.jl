@testset "KW" begin
    @test @kw(a=2) === FastKeywords.KW{:a, Int}(2)
    @test (@kw a=2) === FastKeywords.KW{:a, Int}(2)

    @test FastKeywords.name(@kw(a=2)) === :a
    @test get(@kw(a=2)) === 2
end
