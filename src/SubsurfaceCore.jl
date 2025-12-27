module SubsurfaceCore
using CairoMakie
using LinearAlgebra
using Turing
using Distributions
using Statistics
using Enzyme
using UnPack
import Base: show

include("abstract_types.jl")
include("utils.jl")

include("inverse/bounds_transformation.jl")
include("inverse/utils.jl")

include("probabilistic/respDistribution.jl")
include("probabilistic/utils.jl")
include("probabilistic/core.jl")
include("probabilistic/inverse.jl")
include("probabilistic/post_inv_utils.jl")

include("plots/utils.jl")
include("plots/plots.jl")
include("plots/prob_utils.jl")

# export μ

# abstracts
export AbstractModel, AbstractResponse
export AbstractGeophyModel, AbstractGeophyResponse
export AbstractRockphyModel, AbstractRockphyResponse

export AbstractModelDistribution, AbstractResponseDistribution
export AbstractGeophyModelDistribution, AbstractGeophyResponseDistribution
export AbstractRockphyModelDistribution, AbstractRockphyResponseDistribution

export transform_utils, sigmoid_tf, pow_tf, log_tf, pow_sigmoid_tf, no_tf, phi_scale_tf
export do_verbose

# plots
export get_scales, get_labels
export plot_response, plot_response!
export plot_model, plot_model!

# probabilistic
export mcmc_cache
export stochastic_inverse
export normal_dist, uniform_dist
export to_dist_nt

## post_prob
export get_model_list, get_ρ_at_z
export get_kde_image, get_kde_image!, get_mean_std_image, get_mean_std_image!

## utils
export copy, from_nt, to_nt, to_resp_nt
export default_params, sample_type
export forward_helper

end
