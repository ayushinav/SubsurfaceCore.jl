# COV_EXCL_START

"""
    plot_response!(axs, vars, resp::response; errs=zero(resp), plt_type=:plot,
        kwargs...)

plots on `axs`, a vector of `axis` corresponding parameters of response `resp`
parameterized on `vars`

## Arguments

  - `axs` : vector of `axis` to plot on
  - `vars` : parameter for forward sol, eg. ω for MT, ab/2 for DC resistivity
  - `resp` : response to be plotted

## Keyword Arguments

  - `errs` : errors in response, should be of the same type as `resp`, defaults to `zero(resp)`

  - `plt_type` : type of plot, available options are :

      + `:scatter` : data points are plotted as points
      + `:plot` : data points are connected in a curve
      + `:errors` : plot errors along with the data points
        Defaults to `:plot`
  - `kwargs` : keyword arguments to be splatted into the `Makie` plotting routine

## Usage

Checkout relevant documentation
"""
function plot_response!(args...; kwargs...)
    error("Load a Makie backend first, e.g. `using CairoMakie`.")
end

"""
    plot_response(vars, resp::response; errs=zero(resp), plt_type=:plot,
        kwargs...)

returns a figure and `axis` with plots of corresponding parameters of response `resp`
parameterized on `vars`

## Arguments

  - `vars` : parameter for forward sol, eg. ω for MT, ab/2 for DC resistivity
  - `resp` : response to be plotted

## Keyword Arguments

  - `errs` : errors in response, should be of the same type as `resp`, defaults to `zero(resp)`

  - `plt_type` : type of plot, available options are :

      + `:scatter` : data points are plotted as points
      + `:plot` : data points are connected in a curve
      + `:errors` : plot errors along with the data points
        Defaults to `:plot`
  - `kwargs` : keyword arguments to be splatted into the `Makie` plotting routine

## Usage

Checkout relevant documentation
"""
function plot_response(args...; kwargs...)
    error("Load a Makie backend first, e.g. `using CairoMakie`.")
end

"""
    plot_model!(ax, model::m_type; half_space_thickness=1.25 * sum(model.h),
        kwargs...)

plots on `ax` the geophysical model parameterized by `model`

## Arguments

  - `ax` : `axis` on which models are plotted
  - `model` : geophysical model to be plotted

## Keyword Arguments

  - `half_space_thickness` : thickness of last layer (extent to which the last layer
    aka the half space should go), defaults to 1.25 × total model thickness

  - `kwargs` : keyword arguments to be splatted into the `Makie` plotting routine

## Usage

Checkout relevant documentation
"""
function plot_model!(args...; kwargs...)
    error("Load a Makie backend first, e.g. `using CairoMakie`.")
end

"""
    plot_model(model::m_type; half_space_thickness=1.25 * sum(model.h),
        kwargs...)

returns a `figure` and an `axis` with the plot of geophysical model parameterized by `model`

## Arguments

  - `ax` : `axis` on which models are plotted
  - `model` : geophysical model to be plotted

## Keyword Arguments

  - `half_space_thickness` : thickness of last layer (extent to which the last layer
    aka the half space should go), defaults to 1.25 × total model thickness

  - `kwargs` : keyword arguments to be splatted into the `Makie` plotting routine

## Usage

Checkout relevant documentation
"""
function plot_model(args...; kwargs...)
    error("Load a Makie backend first, e.g. `using CairoMakie`.")
end

# COV_EXCL_STOP
