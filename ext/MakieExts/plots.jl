# COV_EXCL_START
## response plots

function plot_response!(axs, vars, resp::response; errs=zero(resp), plt_type=:plot,
        kwargs...) where {response <: AbstractGeophyResponse}
    k = fieldnames(response)

    if plt_type === :plot
        for i in eachindex(axs)
            lines!(axs[i], vars, getproperty(resp, k[i]); kwargs...)
            xscale, yscale = get_scales(response, Val(k[i]))

            axs[i].xscale = xscale
            axs[i].yscale = yscale

            xlabel, ylabel = get_labels(response, Val(k[i]))

            axs[i].xlabel = xlabel
            axs[i].ylabel = ylabel
        end

    elseif plt_type === :scatter
        for i in eachindex(axs)
            scatter!(axs[i], vars, getproperty(resp, k[i]); kwargs...)
            xscale, yscale = get_scales(response, Val(k[i]))

            axs[i].xscale = xscale
            axs[i].yscale = yscale

            xlabel, ylabel = get_labels(response, Val(k[i]))

            axs[i].xlabel = xlabel
            axs[i].ylabel = ylabel
        end
    elseif plt_type === :errors
        for i in eachindex(axs)
            errorbars!(axs[i], vars, getproperty(resp, k[i]),
                getproperty(errs, k[i]) ./ 2; kwargs...)
            xscale, yscale = get_scales(response, Val(k[i]))

            axs[i].xscale = xscale
            axs[i].yscale = yscale

            xlabel, ylabel = get_labels(response, Val(k[i]))

            axs[i].xlabel = xlabel
            axs[i].ylabel = ylabel
        end
    end
end

function plot_response(vars, resp::response; errs=zero(resp), plt_type=:plot,
        kwargs...) where {response <: AbstractGeophyResponse}
    k = fieldnames(response)
    f = Figure()
    axs = [Axis(f[i, 1]) for i in eachindex(k)]

    plot_response!(axs, vars, resp; errs=errs, plt_type=plt_type, kwargs...)

    return f, axs
end

## model plots
function plot_model!(ax,
        model::m_type;
        half_space_thickness=1.25 * sum(model.h),
        kwargs...) where {m_type <: AbstractGeophyModel{<:AbstractVector, <:AbstractVector}}
    # ax = f.content[1]
    m = model.m
    h = model.h

    xlabel_, ylabel_ = get_labels(m_type)

    m_vec = [m[1], m...]
    h_v = cumsum(h)
    h_vec = [1.0f-2, h_v..., half_space_thickness]

    stairs!(ax, m_vec, h_vec; step=:post, kwargs...)
    ax.xscale = first(get_scales(m_type))
    ax.xlabel = xlabel_
    ax.ylabel = ylabel_
    ax.yreversed = true
    nothing
end

function plot_model(model::m_type;
        half_space_thickness=1.25 * sum(model.h),
        kwargs...) where {m_type <: AbstractGeophyModel{<:AbstractVector, <:AbstractVector}}
    fig = Figure()
    ax = Axis(fig[1, 1])

    plot_model!(ax, model; half_space_thickness=half_space_thickness, kwargs...)
    ax.yreversed = true

    fig, ax
end
# COV_EXCL_STOP
