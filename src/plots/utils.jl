get_scales(::Type{T}) where {T <: AbstractGeophyModel} = identity, identity
get_labels(::Type{T}) where {T <: AbstractGeophyModel} = "", "z (m)"
