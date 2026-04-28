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

function from_nt(::Type{m}, vars) where {m}
    # construct a tuple containing the values for the type in m
    vals = map(fieldnames(m)) do k
        getfield(vars, k)
    end

    m(vals...)
end

to_nt(::Nothing) = (;) # COV_EXCL_LINE

function to_nt(m)
    # construct a tuple containing the values for the type in m
    vals = map(propertynames(m)) do k
        getproperty(m, k)
    end

    NamedTuple{propertynames(m)}(vals)
end

to_resp_nt(d::T) where {T <: AbstractResponse} = to_nt(d)

# forward manipulation

forward(m::Nothing, p, params=(;)) = nothing # COV_EXCL_LINE
default_params(::Type{Nothing}) = (;) # COV_EXCL_LINE

function forward_helper(
        m::Type{T}, m0, vars, response_trans_utils, params) where {T <: AbstractModel}
    model = from_nt(m, m0)
    resp_nt = to_resp_nt(forward(model, vars, params))
    @show response_trans_utils
    for k in propertynames(resp_nt)
        broadcast!(response_trans_utils[k].tf, resp_nt[k], resp_nt[k])
    end
    return resp_nt
end
