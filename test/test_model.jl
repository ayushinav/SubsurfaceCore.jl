mutable struct testModel{T1,T2} <: AbstractModel
    x1::T1
    x2::T2
end

mutable struct testResponse{T1,T2} <: AbstractResponse
    y1::T1
    y2::T2
end

const no_tf = (y1 = lin_tf, y2 = lin_tf)

import SubsurfaceCore: forward, sample_type, default_params, forward_helper

SubsurfaceCore.default_params(::Type{testModel}) = (;)
function SubsurfaceCore.forward(
    m::testModel,
    vars,
    response_trans_utils = no_tf,
    params = (;),
)
    y1 = @. m.x1 + m.x2
    y2 = @. m.x1 * m.x2
    return testResponse(y1, y2)
end

from_nt(testModel, (; x1 = [2.0], x2 = [4.0]))

function SubsurfaceCore.forward_helper(
    m::Type{T},
    m0,
    vars,
    response_trans_utils,
    params,
) where {T<:testModel}
    model = from_nt(m, m0)
    resp_nt = to_resp_nt(forward(model, vars, params))
    for k in propertynames(resp_nt)
        broadcast!(response_trans_utils[k].tf, resp_nt[k], resp_nt[k])
    end
    return resp_nt
end

mutable struct testModelDistribution{
    T1<:Union{Distribution,AbstractArray},
    T2<:Union{Distribution,AbstractArray},
} <: AbstractModelDistribution
    x1::T1
    x2::T2
end

mutable struct testResponseDistribution{
    T1<:Union{Function,Nothing},
    T2<:Union{Function,Nothing},
} <: AbstractResponseDistribution
    y1::T1
    y2::T2
end

SubsurfaceCore.sample_type(::testModelDistribution) = testModel
