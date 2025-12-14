@testitem "utils" tags = [:utils] begin
    using Test, JET, Distributions

    include("test_model.jl")

    @inferred from_nt(testModel, (; x1=[2.0], x2=[4.0]))
    @test_opt from_nt(testModel, (; x1=[2.0], x2=[4.0]))
    @test_call from_nt(testModel, (; x1=[2.0], x2=[4.0]))

    @inferred forward_helper(testModel, (; x1=[2.0], x2=[4.0]), nothing, no_tf, nothing)
    @test_opt forward_helper(testModel, (; x1=[2.0], x2=[4.0]), nothing, no_tf, nothing)
    @test_call forward_helper(testModel, (; x1=[2.0], x2=[4.0]), nothing, no_tf, nothing)
end
