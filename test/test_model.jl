mutable struct testModel{T1, T2} <: AbstractModel
    x1::T1
    x2::T2
end

mutable struct testResponse{T1, T2} <: AbstractResponse
    y1::T1
    y2::T2
end

const my_tf = (y1=no_tf, y2=no_tf)

import SubsurfaceCore: forward, sample_type, default_params, forward_helper

SubsurfaceCore.default_params(::Type{testModel}) = (;)
function SubsurfaceCore.forward(m::testModel, vars, response_trans_utils=my_tf, params=(;))
    y1 = @. m.x1 + m.x2
    y2 = @. m.x1 * m.x2
    return testResponse(y1, y2)
end

my_model = from_nt(testModel, (; x1=[2.0], x2=[4.0]))

mutable struct testModelDistribution{
    T1 <: Union{Distribution, AbstractArray}, T2 <: Union{Distribution, AbstractArray}} <:
               AbstractModelDistribution
    x1::T1
    x2::T2
end

mutable struct testResponseDistribution{
    T1 <: Union{Function, Nothing}, T2 <: Union{Function, Nothing}} <:
               AbstractResponseDistribution
    y1::T1
    y2::T2
end

SubsurfaceCore.sample_type(::testModelDistribution) = testModel
