module SubsurfaceCoreMakieExt

using SubsurfaceCore, MCMCChains, Distributions, Makie
import SubsurfaceCore: plot_response!, plot_response, plot_model!, plot_model,
                       get_kde_image!, get_kde_image, get_mean_std_image!,
                       get_mean_std_image, get_kde, gaussian_kernel

include("MakieExts/plots.jl")
include("MakieExts/prob_utils.jl")

end
