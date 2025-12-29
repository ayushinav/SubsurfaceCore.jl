"""
    mutable struct struct mcmc_cache{T1 <: AbstractGeophyModelDistribution, T2 <: AbstractGeophyResponseDistribution}
        apriori::T1
        likelihood::T2
        n_samples::Int
        sampler
    end

placeholder to store

  - apriori in the form of any subtype of [`AbstractModelDistribution`](@ref)
  - likelihood in the form of any subtype of [`AbstractResponseDistribution`](@ref)
  - number of samples to obtain in `n_samples`
  - `Turing.jl` sampler to be used in `sampler`
"""
mutable struct mcmc_cache{
    T1 <: AbstractModelDistribution, T2 <: AbstractResponseDistribution}
    apriori::T1
    likelihood::T2
    n_samples::Int
    sampler
end

"""
    @model function mcmc_turing(
        m_sample::model,
        vars,
        r_obs::NamedTuple,
        err_resp::MTResponse,
        mDist::mdist,
        rDist::rdist;
        response_fields::Vector{Symbol}= [k for k ∈ fieldnames(typeof(rDist))],
        model_fields::Vector{Symbol}= [k for k ∈ fieldnames(typeof(mDist))],
        trans_utils::NamedTuple = (m = log_tf, h = no_tf)
        ) where {model <: AbstractModel, mdist <: AbstractModelDistribution, rdist <: AbstractResponseDistribution}

makes a `Turing.jl` model to perform MCMC sampling

### Variables:

  - `vars`: variables that need to be passed into the `forward` function along with `model` to generate a `response`
  - `r_obs`: named tuple containing the observed data, with the same keys as the fields in the corresponding `response`
  - `err_resp`: `response` variable that contains the errors
  - `mDist`: any subtype of [`AbstractModelDistribution`](@ref) contains the apriori information
  - `rDist`: any subtype of [`AbstractResponseDistribution`](@ref) contains the likelihood information

### Keyword/optional arguments

  - `response_fields`:  which fields in `response` to invert for
  - `model_fields`: fields in `model` to draw inference on
  - `trans_utils`: to transform the model field variables to and from computational (inference) domain
"""
# @model function mcmc_turing(const_nt, ::Val{m_type},
#         # ::Val{m_type}, vars, r_obs, err_resp, mDist::mdist, rDist::rdist,
#         vars, r_obs, err_resp, mDist::mdist, rDist::rdist,
#         params, model_trans_utils, response_trans_utils,
#         response_fields, model_fields, count) where {mdist, rdist, m_type}

#     m_ = map(model_fields) do k
#         var ~ getfield(mDist, k)
#         broadcast!(getfield(model_trans_utils, k).tf, var, var)
#         return var
#     end

#     # count.c +=1 

#     var_nt = NamedTuple{model_fields}(m_)
#     total_nt = merge(const_nt, var_nt)

#     r_sample = forward_helper(m_type, total_nt, vars, response_trans_utils, params)

#     for k in response_fields
#         r_obs[k] ~ getfield(rDist, k)(getfield(r_sample, k), getfield(err_resp, k) .^ 2)
#     end

    
# end



# 1. The Generator Helper (Handles Params Type-Stably)
@generated function sample_params_impl(mDist, trans_utils, fields::Tuple)
    # Get symbols from the type parameters of the Tuple
    field_names = fields.parameters
    N = length(field_names)
    
    exprs = []
    val_names = []
    
    for i in 1:N
        # We need the actual symbol value
        k = field_names[i] 
        val_name = Symbol("val_$i")
        push!(val_names, val_name)
        
        # Build the code block for this parameter
        block = quote
            # Sample from distribution
            $val_name ~ getfield(mDist, $(QuoteNode(k)))
            
            # Apply transform
            # We use a check to ensure we don't broadcast on scalars if not needed,
            # or we assume strict vector usage as per your previous code.
            tf_obj = getfield(trans_utils, $(QuoteNode(k)))
            broadcast!(tf_obj.tf, $val_name, $val_name)
        end
        push!(exprs, block)
    end
    
    # Return a NamedTuple
    # Construct expression: (; k1=val_1, k2=val_2)
    nt_construction = :(NamedTuple{($(QuoteNode.(field_names)...),)}(($(val_names...),)))
    
    return quote
        $(exprs...)
        return $nt_construction
    end
end

# 2. The Main Model
@model function mcmc_turing(const_nt, ::Val{m_type},
        vars, r_obs, err_resp, mDist, rDist,
        params, model_trans_utils, response_trans_utils,
        response_fields::Tuple, model_fields::Tuple) where {m_type}

    # --- Step 1: Sample Params (Type-Stable via Generated Function) ---
    # This expands to a flat list of "~" statements.
    sampled_nt = sample_params_impl(mDist, model_trans_utils, model_fields)

    # --- Step 2: Merge & Forward ---
    total_nt = merge(sampled_nt, const_nt)
    r_sample = forward_helper(m_type, total_nt, vars, response_trans_utils, params)

    # --- Step 3: Likelihood (Standard Loop over Tuple) ---
    for k in response_fields
        r_obs[k] ~ getfield(rDist, k)(getfield(r_sample, k), getfield(err_resp, k) .^ 2)
    end
end