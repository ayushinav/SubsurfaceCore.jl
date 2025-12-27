sample_type(::Type{Nothing}) = Nothing # COV_EXCL_LINE

# NamedTuple manipulation

to_dist_nt(d::T) where {T <: AbstractModelDistribution} = to_nt(d) # COV_EXCL_LINE
to_dist_nt(d::T) where {T <: AbstractResponseDistribution} = to_nt(d) # COV_EXCL_LINE
to_dist_nt(::Nothing) = (;) # COV_EXCL_LINE
