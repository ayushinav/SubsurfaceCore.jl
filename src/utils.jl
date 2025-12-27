# utils to help bump for Abstract types
# COV_EXCL_START
import Base: copy
function copy(x::resp) where {resp <: AbstractResponse}
    typeof(x)([copy(getfield(x, k)) for k in fieldnames(resp)]...)
end
function copy(x::model) where {model <: AbstractModel}
    typeof(x)([copy(getfield(x, k)) for k in fieldnames(model)]...)
end
# COV_EXCL_STOP

# NamedTuple manipulation

function from_nt(::Type{Nothing}; nt::NamedTuple)
    (;)
end

@generated function from_nt(::Type{T}, nt::NamedTuple) where {T}
    fnames = fieldnames(T)
    args = [:(getproperty(nt, $(QuoteNode(f)))) for f in fnames]
    return :(T($(args...)))
end

to_nt(::Nothing) = (;) # COV_EXCL_LINE

@generated function to_nt_impl(s, ::Val{F}) where {F}
    exs = [:(getfield(s, $(QuoteNode(fname)))) for fname in F]
    :(NamedTuple{$F}(($(exs...),)))
end

function to_nt(s)
    T = typeof(s)
    N = fieldnames(T)
    to_nt_impl(s, Val(N))
end

to_resp_nt(d::T) where {T <: AbstractResponse} = to_nt(d)

# forward manipulation

forward(m::Nothing, p, params=(;)) = nothing # COV_EXCL_LINE
default_params(::Type{Nothing}) = (;) # COV_EXCL_LINE

function forward_helper(
        m::Type{T}, m0, vars, response_trans_utils, params) where {T <: AbstractModel}
    model = from_nt(m, m0)
    resp_nt = to_resp_nt(forward(model, vars, response_trans_utils, params))
    return resp_nt
end
