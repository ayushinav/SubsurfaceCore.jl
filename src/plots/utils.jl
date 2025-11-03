get_scales(::Type{T}, val_) where {T <: AbstractGeophyModel} = identity, identity
get_labels(::Type{T}, val_) where {T <: AbstractGeophyModel} = "", "z (m)"
