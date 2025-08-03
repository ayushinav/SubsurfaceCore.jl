sample_type(::Type{Nothing}) = Nothing

# NamedTuple manipulation

to_dist_nt(d::T) where {T <: AbstractModelDistribution} = to_nt(d)
to_dist_nt(d::T) where {T <: AbstractResponseDistribution} = to_nt(d)
to_dist_nt(::Nothing) = (;)
