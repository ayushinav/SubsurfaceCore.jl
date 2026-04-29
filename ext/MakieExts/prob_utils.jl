# COV_EXCL_START

function get_kde_image!(ax,
        chain::C,
        mDist::mdist;
        K=gaussian_kernel,
        half_space_depth=nothing,
        kde_transformation_fn=identity,
        return_kde_mat=false,
        trans_utils=(m=no_tf, h=no_tf),
        grid=(m=collect(-1:0.1:5), z=cumsum(mDist.h)),
        kwargs...) where {C <: Chains,
        mdist <: AbstractGeophyModelDistribution{<:Distribution, <:AbstractVector}}
    preds = []
    for k in chain.name_map.parameters
        push!(preds, chain[k].data[:])
    end
    pred = hcat(preds...)

    h_length = length(mDist.h)
    kde_img = zeros(length(grid.m), h_length + 1)  # nₘ x nₕ

    for i in 1:h_length
        kde_img[:, i] .= get_kde(pred[:, i], grid.m; Κ=K)
        norm_factor = sum(kde_img[:, i])
        kde_img[:, i] .= kde_img[:, i] ./ norm_factor
    end

    kde_img[:, end] .= copy(kde_img[:, end - 1])

    isnothing(half_space_depth) && (half_space_depth = sum(mDist.h) * 1.25)
    zs = [0, cumsum(mDist.h)..., half_space_depth]

    ms = broadcast(trans_utils.m.tf, grid.m)
    hm = heatmap!(ax, ms, zs, kde_transformation_fn.(kde_img); kwargs...)
    ax.yreversed = true

    if return_kde_mat
        return hm, (ms, zs, kde_transformation_fn.(kde_img))
    else
        return hm
    end
end

function get_kde_image!(ax,
        chain::C,
        mDist::mdist;
        K=gaussian_kernel,
        half_space_depth=nothing,
        kde_transformation_fn=identity,
        return_kde_mat=false,
        trans_utils=(;),
        grid=(m=collect(-1:0.1:5), z=cumsum(mean(mDist.h))),
        kwargs...) where {C <: Chains,
        mdist <: AbstractGeophyModelDistribution{<:Distribution, <:Distribution}}
    preds = []
    for k in chain.name_map.parameters
        push!(preds, chain[k].data[:])
    end
    pred = hcat(preds...)

    m_length = length(rand(mDist.m))
    h_length = length(rand(mDist.h))

    trans_utils_ = (; m=no_tf, h=no_tf, trans_utils...)

    broadcast!(trans_utils_.h.tf, view(pred, :, (m_length + 1):(m_length + h_length)),
        view(pred, :, (m_length + 1):(m_length + h_length)))

    isnothing(half_space_depth) && (half_space_depth = grid.z[end] * 1.25)
    zs = [0, grid.z..., grid.z[end] .+ range(0.0, half_space_depth; length=10)...]

    m2 = zeros(eltype(pred), size(pred, 1), length(zs))
    for i in axes(pred, 1)
        m2[i, :] .= get_ρ_at_z(pred[i, :], zs)
    end

    z_length = length(zs)
    kde_img = zeros(length(grid.m), z_length)  # nₘ x nₕ

    for i in 1:z_length
        kde_img[:, i] .= get_kde(m2[:, i], grid.m; Κ=K)
        norm_factor = sum(kde_img[:, i])
        kde_img[:, i] .= kde_img[:, i] ./ norm_factor
    end

    ms = broadcast(trans_utils_.m.tf, grid.m)
    hm = heatmap!(ax, ms, zs, kde_transformation_fn.(kde_img); kwargs...)
    ax.yreversed = true

    # broadcast!(trans_utils_.m.tf, view(pred, :, 1:m_length), view(pred, :, 1:m_length))
    # broadcast!(trans_utils_.h.tf, view(pred, :, (m_length + 1):(m_length + h_length)),
    #     view(pred, :, (m_length + 1):(m_length + h_length)))

    if return_kde_mat
        return hm, (ms, zs, kde_transformation_fn.(kde_img))
    else
        return hm
    end
end

function get_kde_image(args...; return_kde_mat=false, kwargs...)
    fig = Figure()
    ax = Axis(fig[1, 1])
    kde_img = get_kde_image!(ax, args...; return_kde_mat=return_kde_mat, kwargs...)

    if return_kde_mat
        return fig, kde_img
    else
        return fig
    end
end

function get_mean_std_image!(ax,
        chain::C,
        mDist::mdist;
        confidence_interval=0.95,
        half_space_depth=nothing,
        mean_kwargs=(;),
        std_plus_kwargs=(;),
        std_minus_kwargs=(;),
        trans_utils=(m=no_tf, h=no_tf),
        z_points=cumsum(mDist.h)) where {C <: Chains,
        mdist <: AbstractGeophyModelDistribution{<:Distribution, <:AbstractVector}}
    preds = []
    for k in chain.name_map.parameters
        push!(preds, chain[k].data[:])
    end
    pred = hcat(preds...)

    m_type = sample_type(mDist)

    const_fields = [f for f in fieldnames(m_type) if !(f in [:m])]
    const_vals = [getproperty(mDist, k) for k in const_fields]
    const_nt = (; zip(const_fields, const_vals)...)

    μ_m = mean(pred; dims=1)[:]

    μ₊_m = [quantile(pred[:, i], 1 - (1 - confidence_interval) / 2) for i in axes(pred, 2)]
    μ₋_m = [quantile(pred[:, i], (1 - confidence_interval) / 2) for i in axes(pred, 2)]

    # @show μ₋_m
    # @show μ₊_m

    isnothing(half_space_depth) && (half_space_depth = sum(mDist.h) * 1.25)

    mean_kwargs = (; label="mean", color=:blue, mean_kwargs...)

    std_plus_kwargs = (label="$(100* round(confidence_interval))% bounds",
        color=:green, std_plus_kwargs...)
    std_minus_kwargs = (color=:green, std_minus_kwargs...)

    m_mean = from_nt(m_type, (; m=trans_utils.m.tf.(μ_m), const_nt...))
    m_ub = from_nt(m_type, (; m=trans_utils.m.tf.(μ₊_m), const_nt...))
    m_lb = from_nt(m_type, (; m=trans_utils.m.tf.(μ₋_m), const_nt...))
    plot_model!(ax, m_mean; mean_kwargs...)
    plot_model!(ax, m_ub; std_plus_kwargs...)
    plot_model!(ax, m_lb; std_minus_kwargs...)

    nothing
end

function get_mean_std_image!(ax,
        chain::C,
        mDist::mdist;
        confidence_interval=0.95,
        half_space_depth=nothing,
        mean_kwargs=(;),
        std_plus_kwargs=(;),
        std_minus_kwargs=(;),
        trans_utils=(;),
        z_points=cumsum(mean(mDist.h))) where {C <: Chains,
        mdist <: AbstractGeophyModelDistribution{<:Distribution, <:Distribution}}
    preds = []
    for k in chain.name_map.parameters
        push!(preds, chain[k].data[:])
    end
    pred = hcat(preds...)

    m_length = length(rand(mDist.m))
    h_length = length(rand(mDist.h))

    trans_utils_ = (; m=no_tf, h=no_tf, trans_utils...)

    broadcast!(trans_utils_.h.tf, view(pred, :, (m_length + 1):(m_length + h_length)),
        view(pred, :, (m_length + 1):(m_length + h_length)))

    isnothing(half_space_depth) && (half_space_depth = z_points[end] * 1.25)
    zs = [0, z_points..., z_points[end] .+ range(0.0, half_space_depth; length=10)...]

    m2 = zeros(eltype(pred), size(pred, 1), length(zs))
    for i in axes(pred, 1)
        m2[i, :] .= get_ρ_at_z(pred[i, :], zs)
    end

    μ_m = mean(m2; dims=1)[:]

    μ₊_m = [quantile(m2[:, i], 1 - (1 - confidence_interval) / 2) for i in axes(m2, 2)]
    μ₋_m = [quantile(m2[:, i], (1 - confidence_interval) / 2) for i in axes(m2, 2)]

    isnothing(half_space_depth) && (half_space_depth = sum(mDist.h) * 1.25)

    mean_kwargs = (; label="mean", color=:blue, mean_kwargs...)

    std_plus_kwargs = (label="$(100 * round(confidence_interval))% bounds",
        color=:green, std_plus_kwargs...)
    std_minus_kwargs = (color=:green, std_minus_kwargs...)

    lines!(ax, trans_utils_.m.tf.(μ_m), zs; mean_kwargs...)
    lines!(ax, trans_utils_.m.tf.(μ₊_m), zs; std_plus_kwargs...)
    lines!(ax, trans_utils_.m.tf.(μ₋_m), zs; std_minus_kwargs...)

    nothing
end

function get_mean_std_image(args...; kwargs...)
    fig = Figure()
    ax = Axis(fig[1, 1])
    get_mean_std_image!(ax, args...; kwargs...)
    fig
end
# COV_EXCL_STOP
