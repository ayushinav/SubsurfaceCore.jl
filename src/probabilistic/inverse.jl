"""
    get_stochastic_inverse_model(
        r_obs, err_resp, vars, alg_cache;
        model_trans_utils, response_trans_utils, params
        )

## Returns

returns a `DynamicPPL` model and a counter variable. The `DynamicPPL` model can be sampled using Turing or Pigeons, and the counter variable records the number of forward calls.

## Arguments

  - `r_obs`: `response` that needs to inverted for
  - `err_resp`: `response` variable containing the errors associated with observed response
  - `vars`: variables that need to be passed into the `forward` function along with `model` to generate a `response`. Use `nothing` if no extra information is needed.
  - `alg_cache`: contains the prior distributions and likelihood functions

### Optional Keyword Arguments

  - `model_trans_utils`: A named tuple containing `transform_utils` for the fields of model that need to be scaled/modified,
    defaults to no scaling.
  - response_trans_utils`: A named tuple containing to scale/ modify the response, defaults to no scaling.
  - `params` : Settings needed for forward calculation, defaults to `default_params`
"""
function get_stochastic_inverse_model(
        r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache;
        model_trans_utils::NamedTuple=(;), # need to take care of this
        response_trans_utils::NamedTuple=(;),
        params=(;)) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}

    # segregate the constants and the Distribution parts of the alg_cache

    apriori = to_dist_nt(alg_cache.apriori)

    const_nt = filter(k -> !isa(k, Distribution), apriori)
    model_fields = filter(k -> isa(getfield(apriori, k), Distribution), keys(apriori))

    var_tp = map(model_fields) do k
        rand(getfield(apriori, k))
    end
    var_nt = NamedTuple{model_fields}(var_tp)

    resp_nt = to_resp_nt(r_obs)
    likelihood = to_dist_nt(alg_cache.likelihood)
    response_fields = filter(k -> isa(getfield(likelihood, k), Function), keys(likelihood))

    # putting together trans_utils for all the fields

    # model transform_utils

    model_trans_utils_ = NamedTuple{keys(apriori)}(ntuple(i -> no_tf, length(apriori)))
    model_trans_utils_ = merge(model_trans_utils_, model_trans_utils)

    # response transform_utils

    response_trans_utils_ = NamedTuple{keys(likelihood)}(ntuple(i -> no_tf, length(likelihood)))
    response_trans_utils_ = merge(response_trans_utils_, response_trans_utils)

    m_type = sample_type(alg_cache.apriori)

    if isempty(params)
        params = default_params(m_type)
    end

    msg = """
    variables to be inferred : $(model_fields)
    variables used for inference : $(response_fields)
    model type : $(m_type)
    """
    @info msg

    counter_var = counter(0)

    mcmc_model = mcmc_turing(var_nt, const_nt, #
        Val(m_type), vars, resp_nt, # ::NamedTuple
        to_resp_nt(err_resp), # ::response
        apriori, # ::NamedTuple
        likelihood, # ::responseDistribution
        params, model_trans_utils_,
        response_trans_utils_,  #
        response_fields, model_fields, counter_var)

    return mcmc_model, counter_var
end

"""
    stochastic_inverse(
        r_obs, err_resp, vars, alg_cache, sampler, n_samples;
        n_chains, model_trans_utils, response_trans_utils, params, kwargs...
        )

function to perform stochastic sampling

## Returns

    `Chain` containing the samples. Note that all the variables will be named `m`.

## Arguments

  - `r_obs`: `response` that needs to inverted for
  - `err_resp`: `response` variable containing the errors associated with observed response
  - `vars`: variables that need to be passed into the `forward` function along with `model` to generate a `response`. Use `nothing` if no extra information is needed.
  - `alg_cache`: contains the prior distributions and likelihood functions
  - `sampler`: contains the sampler for MCMC chains
  - `n_samples`: Number of samples to obtain for MCMC, defaults to 10. For `Pigeons` samplers, this should be a power of 2, e.g. 1024, 2048, 4096, 8192, ...

### Optional Keyword Arguments

  - `n_chains` : Number of chains to use
  - `model_trans_utils`: A named tuple containing `transform_utils` for the fields of model that need to be scaled/modified,
    defaults to no scaling.
  - response_trans_utils`: A named tuple containing to scale/ modify the response, defaults to no scaling.
  - `params` : Settings needed for forward calculation, defaults to `default_params`
  - `kwargs` : keyword arguments to be splatted into sampling function
"""
function stochastic_inverse(val, r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache,
        sampler, n_samples=10; n_chains=1, model_trans_utils::NamedTuple=(;),
        response_trans_utils::NamedTuple=(;), params=(;),
        kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}
    error("$(Base.moduleroot(parentmodule(typeof(sampler)))) not supported yet. Check out documentation on external samplers or open a new issue with SubsurfaceCore.jl.")
end

function stochastic_inverse(
        r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache, sampler, n_samples=10;
        kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}
    stochastic_inverse(Val(Base.moduleroot(parentmodule(typeof(sampler)))), r_obs,
        err_resp, vars, alg_cache, sampler, n_samples; kwargs...)
end
