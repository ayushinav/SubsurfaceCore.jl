# utils to help bump for Abstract types

import Base: copy
function copy(x::resp) where {resp <: AbstractResponse}
    typeof(x)([copy(getfield(x, k)) for k in fieldnames(resp)]...)
end
function copy(x::model) where {model <: AbstractModel}
    typeof(x)([copy(getfield(x, k)) for k in fieldnames(model)]...)
end

# NamedTuple manipulation

function from_nt(::Type{Nothing}; nt::NamedTuple)
    (;)
end

@generated function from_nt(::Type{T}, nt::NamedTuple) where {T}
    # @show T
    fnames = fieldnames(T)
    args = [:(getproperty(nt, $(QuoteNode(f)))) for f in fnames]
    return :(T($(args...)))
end

to_nt(::Nothing) = (;)

function to_nt(s)
    T = typeof(s)
    names = fieldnames(T)
    vals = ntuple(i -> getfield(s, names[i]), length(names))
    NamedTuple{names}(vals)
end

to_resp_nt(d::T) where {T <: AbstractResponse} = to_nt(d)

# forward manipulation

forward(m::Nothing, p, params=(;)) = nothing
default_params(::Type{Nothing}) = (;)

function forward_helper(
        m::Type{T}, m0, vars, response_trans_utils, params) where {T <: AbstractGeophyModel}
    model = from_nt(m, m0)
    resp_nt = to_resp_nt(forward(model, vars, response_trans_utils = response_trans_utils, params = params))
    return resp_nt
end

function forward_helper(m::Type{T}, m0, vars, response_trans_utils,
        params) where {T <: AbstractRockphyModel}
    model = from_nt(m, m0)
    resp_nt = to_resp_nt(forward(model, vars, params))
    for k in propertynames(resp_nt)
        broadcast!(response_trans_utils[k].tf, resp_nt[k], resp_nt[k])
    end
    return resp_nt
end
