@testitem "utils" tags=[:utils] begin
    using Test, JET

    include("test_model.jl")

    @inferred to_nt(my_model)
    @test_opt to_nt(my_model)
    @test_call to_nt(my_model)

    @inferred from_nt(testModel, (; x1=[2.0], x2=[4.0]))
    @test_opt from_nt(testModel, (; x1=[2.0], x2=[4.0]))
    @test_call from_nt(testModel, (; x1=[2.0], x2=[4.0]))

    @inferred forward_helper(testModel, (; x1=[2.0], x2=[4.0]), nothing, no_tf, nothing)
    @test_opt forward_helper(testModel, (; x1=[2.0], x2=[4.0]), nothing, no_tf, nothing)
    @test_call forward_helper(testModel, (; x1=[2.0], x2=[4.0]), nothing, no_tf, nothing)
end
