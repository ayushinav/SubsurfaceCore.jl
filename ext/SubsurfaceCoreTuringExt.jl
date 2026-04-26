module SubsurfaceCoreTuringExt

using Turing

function stochastic_inverse(
        r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache, sampler,
        n_samples=10, ::Val{Turing}; n_chains=1, model_trans_utils::NamedTuple=(;), # need to take care of this
        response_trans_utils::NamedTuple=(;), params=(;),
        kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}
    mcmc_model,
    counter_var = get_stochastic_inverse_model(r_obs, err_resp, vars, alg_cache; n_chains,
        model_trans_utils, response_trans_utils, params)

    chains = Turing.sample(mcmc_model, sampler, n_samples; verbose=false, kwargs...)

    @info "$(counter_var.c) forward calls ran"
    return chains
end

function stochastic_inverse(r_obs::resp1,
        err_resp::resp2,
        vars,
        alg_cache::mcmc_cache,
        sampler::S,
        ::Val{Turing};
        n_chains=1,
        model_trans_utils::NamedTuple=(;), # need to take care of this
        response_trans_utils::NamedTuple=(;),
        params=(;),
        kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse,
        S <: Turing.AdvancedVI.VariationalInference}
    mcmc_model,
    counter_var = get_stochastic_inverse_model(r_obs, err_resp, vars, alg_cache; n_chains,
        model_trans_utils, response_trans_utils, params)

    vi_model = vi(mcmc_model, alg_cache)
    @info "$(counter_var.c) forward calls ran"
    return vi_model
end

end
