module SubsurfaceCorePigeonsExt

using SubsurfaceCore
using MCMCChains
import SubsurfaceCore: stochastic_inverse
using Pigeons

function stochastic_inverse(
        ::Val{Pigeons}, r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache,
        sampler, n_samples=10; n_chains=1, model_trans_utils::NamedTuple=(;), # need to take care of this
        response_trans_utils::NamedTuple=(;), params=(;),
        kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}
    mcmc_model,
    counter_var = get_stochastic_inverse_model(
        r_obs, err_resp, vars, alg_cache; model_trans_utils, response_trans_utils, params)

    n_rounds = Int(round(log2(n_samples)))
    pt = pigeons(; target=TuringLogPotential(mcmc_model), n_chains=n_chains, # Λ ~ 6
        n_rounds=n_rounds,   # low to speed up CI
        record=[traces; round_trip; record_default()], kwargs...)
    @info "$(counter_var.c) forward calls ran"
    return Chains(pt)
end

end
