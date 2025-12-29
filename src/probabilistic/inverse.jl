mutable struct counter{T}
    c::T
end

"""
    stochastic_inverse(
        r_obs::response,
        err_resp::response,
        vars,
        alg_cache::mcmc_cache;
        model_trans_utils::NamedTuple = (m = no_tf, h = no_tf)
        )

function to perform sampling

## Returns

    `Chain` containing the samples. Note that all the variables will be named `m0`. If 

## Arguments

  - `r_obs`: `response` that needs to inverted for
  - `err_resp`: `response` variable containing the errors associated with observed response
  - `vars`: variables that need to be passed into the `forward` function along with `model` to generate a `response`
  - `alg_cache`: to tell the compiler what type of stochastic inversion method is to be used

### Optional Keyword Arguments

  - `n_chains` : Number of chains to use
  - `model_trans_utils`: A named tuple containing `transform_utils` for the fields of model that need to be scaled/modified,
    defaults to no scaling.
  - response_trans_utils`: A named tuple containing to scale/ modify the response, defaults to no scaling.
  - `params` : parameters needed for forward calculation
  - `kwargs` : keyword arguments to be splatted into sampling function
"""
function stochastic_inverse(
        r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache; n_chains=1,
        model_trans_utils::NamedTuple=(;), # need to take care of this
        response_trans_utils::NamedTuple=(;),
        params=(;), kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}
    model_fields = Symbol[]

    # segregate the constants and the Distribution parts of the alg_cache

    apriori = to_dist_nt(alg_cache.apriori)

    const_nt = filter(k -> !isa(k, Distribution), apriori)
    model_fields = filter(k -> isa(getfield(apriori, k), Distribution), keys(apriori))

    resp_nt = to_resp_nt(r_obs)
    likelihood = to_dist_nt(alg_cache.likelihood)
    response_fields = filter(k -> isa(getfield(likelihood, k), Function), keys(likelihood))

    # putting together trans_utils for all the fields

    # model transform_utils

    model_trans_utils_ = NamedTuple{keys(apriori)}(ntuple(i -> no_tf, length(apriori)))
    model_trans_utils_ = merge(model_trans_utils_, model_trans_utils)

    # response transform_utils

    response_trans_utils_ = NamedTuple{keys(likelihood)}(ntuple(
        i -> no_tf, length(likelihood)))
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

    k = counter(1)

    mcmc_model = mcmc_turing(const_nt, #
        Val(m_type), vars, resp_nt, # ::NamedTuple
        to_resp_nt(err_resp), # ::response
        apriori, # ::NamedTuple
        likelihood, # ::responseDistribution
        params, model_trans_utils_,
        response_trans_utils_,  #
        response_fields, model_fields, k)

    chains_ = Turing.sample(
        mcmc_model, alg_cache.sampler, alg_cache.n_samples; verbose=false, kwargs...)

    @info "$(k.c) forward calls ran"
    # return mcmc_model
    return chains_
end
