module SubsurfaceCoreTuringExt

using SubsurfaceCore
import SubsurfaceCore: stochastic_inverse
using Turing

function stochastic_inverse(
        ::Val{Turing}, r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache,
        sampler, n_samples=10; n_chains=1, model_trans_utils::NamedTuple=(;),
        response_trans_utils::NamedTuple=(;), params=(;),
        kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}
    mcmc_model,
    counter_var = get_stochastic_inverse_model(
        r_obs, err_resp, vars, alg_cache; model_trans_utils, response_trans_utils, params)

    # TODO : n_chains
    chains = Turing.sample(mcmc_model, sampler, n_samples; verbose=false, kwargs...)

    @info "$(counter_var.c) forward calls ran"
    return chains
end

end
