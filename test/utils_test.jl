@testitem "utils" tags=[:utils] begin
    using Test, JET, Distributions

    include("test_model.jl")

    @inferred to_nt(my_model)
    @test_opt to_nt(my_model)
    @test_call to_nt(my_model)

    @inferred from_nt(testModel, (; x1=[2.0], x2=[4.0]))
    @test_opt from_nt(testModel, (; x1=[2.0], x2=[4.0]))
    @test_call from_nt(testModel, (; x1=[2.0], x2=[4.0]))

    @inferred forward_helper(
        testModel, (; x1=[2.0], x2=[4.0]), nothing, (; y1=no_tf, y2=no_tf), nothing)
    @test_opt forward_helper(
        testModel, (; x1=[2.0], x2=[4.0]), nothing, (; y1=no_tf, y2=no_tf), nothing)
    @test_call forward_helper(
        testModel, (; x1=[2.0], x2=[4.0]), nothing, (; y1=no_tf, y2=no_tf), nothing)
end

@testitem "MCMC type inference" tags=[:utils] begin
    using Test
    using Distributions, JET

    include("test/test_model.jl")

    m = testModel([2.0], [4.0])
    resp = forward(m, [])

    modelD = testModelDistribution(product_distribution([Uniform(0.0, 3.0)]), [4.0])

    respD = testResponseDistribution(normal_dist, normal_dist)
    err_resp = testResponse([0.1], [0.1])

    n_samples = 10_000
    mcache = mcmc_cache(modelD, respD)
    @inferred first(get_stochastic_inverse_model(resp, err_resp, nothing, mcache))

    @test_opt first(get_stochastic_inverse_model(resp, err_resp, nothing, mcache))

    @test_call first(get_stochastic_inverse_model(resp, err_resp, nothing, mcache))
end
