# COV_EXCL_START
"""
    gaussian_kernel(u, σ² = 2)

return gaussian kernel centered at 0, at points given by `u` with std deviation of `σ`
"""
gaussian_kernel(u, σ²=2) = inv(sqrt(2π)) * exp(-u^2 / σ²)

"""
    get_kde(data, xgrid; Κ= gaussian_kernel)

returns distribution of `data` using kernel density estimation

## Arguments

  - `data` : 1D vector to evaluate distribution for
  - `xgrid` : 1D vector to evaluate distribution on

## Keyword Arguments

  - `Κ` : kernel used to evaluate density, defaults to `gaussian_kernel`[@ref]
"""
function get_kde(data, xgrid; Κ=gaussian_kernel)
    σ = std(data)
    n = length(data)
    h = 1.06 * σ * n^(-1/5)
    px = zeros(size(xgrid))
    for (i, x) in enumerate(xgrid)
        s = 0
        for idata in data
            s = s + Κ((x - idata) / h)
        end
        px[i] = inv(length(data) * h) * s
    end
    return px
end

"""
    get_kde_image!(ax,
        chain::C,
        mDist::mdist;
        hm_kwargs=(;),
        cb_kwargs=(;),
        K=gaussian_kernel,
        half_space_depth=nothing,
        kde_transformation_fn = identity,
        return_kde_mat=false,
        trans_utils=(m=no_tf, h=no_tf),
        grid=(m=collect(-1:0.1:5), z=cumsum(mDist.h)))

plots on `fig`, a heatmap of probability distributions sampled by a `chain` using kernel density estimation

## Arguments

  - `ax` : `Axis` on which the heatmap is plotted
  - `chain` : samples in the form `Turing.Chains` from an MCMC sampling
  - `mDist` : *apriori* model distribution used for MCMC sampling

## Keyword Arguments

  - `K` : kernel used to perform kernel density estimation
  - `half_space_depth` : extent of half space, i.e., the last layer, informs how far to extend the half space, defaults to `1.25 × last `
  - `kde_transformation_fn` : a function that transforms the image domain, eg., use `log10` to plot log pdf; defaults to `identity` which implies no bounds_transformation
  - `return_kde_mat` : whether to return the matrix containing the values of heatmap along with corresponding x,y axes; defaults to `false`
  - `trans_utils` : `NamedTuple` containing functions to transform the samples; defaults to no `no_tf` for all parameters
  - `grid` : `NamedTuple` containing grid to evaluate the kernel density on. `m` refers to the points to evaluate kde of model parameters,
    `z` refers to the depth points at which the model samples are inferred, not used if `h` is not sampled.
  - `kwargs` : keyword arguments to be splatted for customizing heatmap

!!! note


Also check relevant tutorial page!
"""
function get_kde_image!(ax, chain, mDist; kwargs...)
    error("Load a Makie backend first, e.g. `using CairoMakie`.")
end

"""
    get_kde_image(chain,
        mDist;
        hm_kwargs=(;),
        cb_kwargs=(;),
        K=gaussian_kernel,
        half_space_depth=nothing,
        kde_transformation_fn = identity,
        return_kde_mat=false,
        trans_utils=(m=no_tf, h=no_tf),
        grid=(m=collect(-1:0.1:5), z=cumsum(mDist.h)))

returns `fig`, a heatmap of probability distributions sampled by a `chain` using kernel density estimation

## Arguments

  - `fig` : Figure on which the heatmap is plotted
  - `chain` : samples in the form `Turing.Chains` from an MCMC sampling
  - `mDist` : *apriori* model distribution used for MCMC sampling

## Keyword Arguments

  - `hm_kwargs` : `NamedTuple` containing keyword arguments for customizing heatmap
  - `cb_kwargs` : `NamedTuple` containing keyword arguments for customizing colorbar
  - `K` : kernel used to perform kernel density estimation
  - `half_space_depth` : extent of half space, i.e., the last layer, informs how far to extend the half space, defaults to `1.25 × last `
  - `kde_transformation_fn` : a function that transforms the image domain, eg., use `log10` to plot log pdf; defaults to `identity` which implies no bounds_transformation
  - `return_kde_mat` : whether to return the matrix containing the values of heatmap along with corresponding x,y axes; defaults to `false`
  - `trans_utils` : `NamedTuple` containing functions to transform the samples; defaults to no `no_tf` for all parameters
  - `grid` : `NamedTuple` containing grid to evaluate the kernel density on. `m` refers to the points to evaluate kde of model parameters,
    `z` refers to the depth points at which the model samples are inferred, not used if `h` is not sampled.

!!! note


Also check relevant tutorial page!
"""
function get_kde_image(args...; kwargs...)
    error("Load a Makie backend first, e.g. `using CairoMakie`.")
end

"""
    get_mean_std_image!(ax,
        chain,
        mDist;
        confidence_interval=0.95,
        half_space_depth=nothing,
        plot_kwargs=nothing,
        trans_utils=(m=no_tf, h=no_tf))

plots on `ax`, a bounds plot (using mean and std deviation) of probability distributions sampled by a `chain` using kernel density estimation

## Arguments

  - `fig` : Axis on which the probability bounds are plotted
  - `chain` : samples in the form `Turing.Chains` from an MCMC sampling
  - `mDist` : *apriori* model distribution used for MCMC sampling

## Keyword Arguments

  - `confidence_interval` : a `confidence_interval` of `0.9` implies 90% of values are within the bounds
  - `half_space_depth` : extent of half space, i.e., the last layer, informs how far to extend the half space, defaults to `1.25 × last `
  - `plot_kwargs` : `NamedTuple` containing keyword arguments for plots
  - `return_kde_mat` : whether to return the matrix containing the values of heatmap along with corresponding x,y axes; defaults to `false`
  - `trans_utils` : `NamedTuple` containing functions to transform the samples; defaults to no `no_tf` for all parameters
  - `z_points` : depth points at which bounds are plotted, not used if `h` is not sampled; defaults to depths corresponding to `mean(h)`

!!! note


Also check relevant tutorial page!
"""
function get_mean_std_image!(ax, chain, mDist; kwargs...)
    error("Load a Makie backend first, e.g. `using CairoMakie`.")
end

"""
    get_mean_std_image(chain,
        mDist;
        confidence_interval=0.95,
        half_space_depth=nothing,
        plot_kwargs=nothing,
        trans_utils=(m=no_tf, h=no_tf))

return `fig`, a figure with a bounds plot (using mean and std deviation) of probability distributions sampled by a `chain` using kernel density estimation

## Arguments

  - `fig` : Axis on which the probability bounds are plotted
  - `chain` : samples in the form `Turing.Chains` from an MCMC sampling
  - `mDist` : *apriori* model distribution used for MCMC sampling

## Keyword Arguments

  - `confidence_interval` : a `confidence_interval` of `0.9` implies 90% of values are within the bounds
  - `half_space_depth` : extent of half space, i.e., the last layer, informs how far to extend the half space, defaults to `1.25 × last `
  - `plot_kwargs` : `NamedTuple` containing keyword arguments for plots
  - `return_kde_mat` : whether to return the matrix containing the values of heatmap along with corresponding x,y axes; defaults to `false`
  - `trans_utils` : `NamedTuple` containing functions to transform the samples; defaults to no `no_tf` for all parameters
  - `z_points` : depth points at which bounds are plotted, not used if `h` is not sampled; defaults to depths corresponding to `mean(h)`

!!! note


Also check relevant tutorial page!
"""
function get_mean_std_image(args...; kwargs...)
    error("Load a Makie backend first, e.g. `using CairoMakie`.")
end
# COV_EXCL_STOP
