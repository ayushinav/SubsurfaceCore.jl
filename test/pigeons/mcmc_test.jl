@testitem "MCMC : SliceSampler I" tags=[:pigeons] begin
    using Test
    using Distributions, Pigeons

    include("../test_model.jl")

    m = testModel([2.0], [4.0])
    resp = forward(m, [])

    modelD = testModelDistribution(product_distribution([Uniform(0.0, 3.0)]), [4.0])

    respD = testResponseDistribution(normal_dist, normal_dist)
    err_resp = testResponse([0.1], [0.1])

    n_samples = 8192
    mcache = mcmc_cache(modelD, respD)
    chains = stochastic_inverse(resp, err_resp, nothing, mcache, SliceSampler(), n_samples)

    m_list = get_model_list(chains, modelD)

    @test size(chains.value.data, 1) == n_samples
    @test all(.≈(mean(chains.value.data; dims=1)[1, 1], m.x1; atol=1e-1))

    @test length(m_list) == n_samples
    @test typeof(first(m_list)) <: testModel
end

@testitem "MCMC : SliceSampler II" tags=[:pigeons] begin
    using Test
    using Distributions, Pigeons

    include("../test_model.jl")

    m = testModel([2.0], [4.0])
    resp = forward(m, [])

    modelD = testModelDistribution(product_distribution([Uniform(0.0, 3.0)]),
        product_distribution([Uniform(0.0, 5.0)]))

    respD = testResponseDistribution(normal_dist, normal_dist)
    err_resp = testResponse([0.1], [0.1])

    n_samples = 10_000
    mcache = mcmc_cache(modelD, respD)
    chains = stochastic_inverse(resp, err_resp, nothing, mcache, SliceSampler(), n_samples)

    m_list = get_model_list(chains, modelD)

    @test size(chains.value.data, 1) == n_samples
    @test all(.≈(mean(chains.value.data; dims=1)[1, 1], m.x1; atol=1e-1))

    @test length(m_list) == n_samples
    @test typeof(first(m_list)) <: testModel
end
