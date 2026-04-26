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
        r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache, sampler,
        n_samples=10, val=Val(parentmodule(typeof(sampler))); n_chains=1,
        model_trans_utils::NamedTuple=(;), # need to take care of this
        response_trans_utils::NamedTuple=(;),
        params=(;), kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}
    error("$(typeof(sampler).name.module) not supported yet. Check out documentation on external samplers or open a new issue with SubsurfaceCore.jl.")
end
