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
  - `response_fields` : fields of response to be used for inference
  - `kwargs` : keyword arguments to be splatted into sampling function
"""
function stochastic_inverse(r_obs::resp1, err_resp::resp2, vars, alg_cache::mcmc_cache;
        n_chains=2, model_trans_utils::NamedTuple=(;), # need to take care of this
        response_trans_utils::NamedTuple=(;), params=(;), response_fields=Symbol[],
        kwargs...) where {resp1 <: AbstractResponse, resp2 <: AbstractResponse}
    model_fields_ = Symbol[]
    # modelD = []
    const_data = []
    const_fields_ = Symbol[]

    # segregate the constants and the Distribution parts of the alg_cache

    apriori = to_dist_nt(alg_cache.apriori)

    for k in keys(apriori)
        if typeof(getfield(apriori, k)) <: Distribution
            push!(model_fields_, Symbol(k))
            # push!(const_data, rand(getfield(apriori, k)))
        else
            push!(const_data, getfield(apriori, k))
            push!(const_fields_, Symbol(k))
        end
    end

    const_fields = Tuple(const_fields_)
    model_fields = Tuple(model_fields_)
    const_nt = NamedTuple{const_fields}(const_data)

    # const_values = map(keys(apriori)) do k
    #     val = getfield(apriori, k)
    #     if !(val isa Distribution)
    #         return val
    #     end
    # end

    likelihood = to_dist_nt(alg_cache.likelihood)
    if response_fields == Symbol[]
        for k in keys(likelihood) # similarly, here it will be propertynames for likelihood being a NamedTuple
            if typeof(getfield(likelihood, k)) <: Function
                push!(response_fields, Symbol(k))
            end
        end
    end

    # putting trans_utils together for all the fields

    trans_utils_arr = []
    for k in keys(apriori)
        if k in keys(model_trans_utils)
            push!(trans_utils_arr, model_trans_utils[k])
        else
            push!(trans_utils_arr, no_tf)
        end
    end

    transf_utils = (; zip(keys(apriori), trans_utils_arr)...) # NamedTuple for trans_utils and defaults

    trans_utils_arr = []
    for k in keys(to_resp_nt(r_obs))
        if k in keys(response_trans_utils)
            push!(trans_utils_arr, getfield(response_trans_utils, k))
        else
            push!(trans_utils_arr, no_tf)
        end
    end

    response_trans_utils = (; zip(keys(to_resp_nt(r_obs)), trans_utils_arr)...)

    m_type = sample_type(alg_cache.apriori)

    if isempty(params)
        params = default_params(m_type)
    end

    # @show to_resp_nt(r_obs)
    # @show to_resp_nt(err_resp)
    msg = """
    variables to be inferred : $(model_fields)
    variables used for inference : $(response_fields)
    model type : $(m_type)
    """
    @info msg

    # m0 = NamedTuple{keys(apriori)}(const_values)
    mcmc_model = mcmc_turing(const_nt, vars, to_resp_nt(r_obs), # ::NamedTuple
        to_resp_nt(err_resp), # ::response
        alg_cache.apriori, # ::NamedTuple
        likelihood, # ::responseDistribution
        params, transf_utils, response_trans_utils, 
        response_fields, model_fields)

    # return Turing.sample(mcmc_model, alg_cache.sampler,
    #     alg_cache.n_samples; verbose=false, kwargs...)

    return mcmc_model
end
