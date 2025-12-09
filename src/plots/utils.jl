# COV_EXCL_START
get_scales(::Type{T}, val_) where {T <: AbstractGeophyModel} = identity, identity
get_labels(::Type{T}, val_) where {T <: AbstractGeophyModel} = "", "z (m)"
# COV_EXCL_STOP
