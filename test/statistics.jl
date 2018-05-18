# This file is a part of Julia. License is MIT: https://julialang.org/license

using Test, Random, LinearAlgebra

@testset "mean" begin
    @test_throws ArgumentError mean(())
    @test mean((1,2,3)) === 2.
    @test mean([0]) === 0.
    @test mean([1.]) === 1.
    @test mean([1.,3]) == 2.
    @test mean([1,2,3]) == 2.
    @test mean([0 1 2; 4 5 6], dims=1) == [2.  3.  4.]
    @test mean([1 2 3; 4 5 6], dims=1) == [2.5 3.5 4.5]
    @test mean(i->i+1, 0:2) === 2.
    @test mean(isodd, [3]) === 1.
    @test mean(x->3x, (1,1)) === 3.

    @test isnan(mean([NaN]))
    @test isnan(mean([0.0,NaN]))
    @test isnan(mean([NaN,0.0]))

    @test isnan(mean([0.,Inf,-Inf]))
    @test isnan(mean([1.,-1.,Inf,-Inf]))
    @test isnan(mean([-Inf,Inf]))
    @test isequal(mean([NaN 0.0; 1.2 4.5], dims=2), reshape([NaN; 2.85], 2, 1))

    # Check that small types are accumulated using wider type
    for T in (Int8, UInt8)
        x = [typemax(T) typemax(T)]
        g = (v for v in x)
        @test mean(x) == mean(g) == typemax(T)
        @test mean(identity, x) == mean(identity, g) == typemax(T)
        @test mean(x, dims=2) == [typemax(T)]'
    end
end

@testset "Issue #17153 and PR #17154" begin
    a = rand(10,10)
    b = copy(a)
    x = mean(a, dims=1)
    @test b == a
    x = mean(a, dims=2)
    @test b == a
end

# dimensional correctness
isdefined(Main, :TestHelpers) || @eval Main include("TestHelpers.jl")
using .Main.TestHelpers: Furlong
@testset "Unitful elements" begin
    r = Furlong(1):Furlong(1):Furlong(2)
    a = Vector(r)
    @test sum(r) == sum(a) == Furlong(3)
    @test cumsum(r) == Furlong.([1,3])
    @test mean(r) == mean(a) == Furlong(1.5)

    # Issue #21786
    A = [Furlong{1}(rand(-5:5)) for i in 1:2, j in 1:2]
    @test mean(mean(A, dims=1), dims=2)[1] === mean(A)
end

@testset "Mean along dimension of empty array" begin
    a0  = zeros(0)
    a00 = zeros(0, 0)
    a01 = zeros(0, 1)
    a10 = zeros(1, 0)
    @test isequal(mean(a0, dims=1)      , fill(NaN, 1))
    @test isequal(mean(a00, dims=(1, 2)), fill(NaN, 1, 1))
    @test isequal(mean(a01, dims=1)     , fill(NaN, 1, 1))
    @test isequal(mean(a10, dims=2)     , fill(NaN, 1, 1))
end
