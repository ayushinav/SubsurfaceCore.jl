# SubsurfaceCore.jl

[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ayushinav/SubsurfaceCore.jl/Tests.yml)
[![codecov](https://codecov.io/gh/ayushinav/SubsurfaceCore.jl/graph/badge.svg?token=VQM6W3DUI4)](https://codecov.io/gh/ayushinav/SubsurfaceCore.jl)
[![](https://img.shields.io/badge/%F0%9F%9B%A9%EF%B8%8F_tested_with-JET.jl-233f9a)](https://github.com/aviatesk/JET.jl)

Provides functionality for Bayesian inference, for use in [Porosity.jl](https://github.com/ayushinav/Porosity.jl). While a quick rundown of the features and essentials is provided below, users are recommended to check out the downstream package and its documentation for more comprehensive tutorials.

## Interface

  - `AbstractRockphyModel` is an abstract type for all types (e.g., conductivity, elastic, viscous and anelastic) of rock physics models.

  - `AbstractGeophyModel` is an abstract type to define models for all types of geophysical methods (e.g., magnetotelluric, DC resistivity, surface waves).
  - `AbstractRockphyModelDistribution` has a structure very similar to that of `AbstractRockphyModel` but is useful to define *a priori* distribution for Bayesian inference of rock physics parameters from geophysical observables. `AbstractGeophyModelDistribution` defines the *a priori* for geophysical inference.
  - `AbstractRockphyResponse` is the abstract type for the estimates of geophysical observables obtained from rock physics models.
  - `AbstractGeophyResponse` is a similar abstract type to store geophysical responses.
  - Subtypes of `AbstractRockphyResponseDistribution` have the similar structure has the corresponding `AbstractRockphyResponse` subtype but defines the likelihood function for Bayesian inference of rock physics parameters. `AbstractGeophyResponseDistribution` has a similar role for geophysical models.
  - `mcmc_cache` : Defines the MCMC sampler to be used for inference, along with the *a priori* distribution, likelihood functions, and number of samples.
  - `transformation_utils` puts together all kinds of transformations commonly used for transformation of data in rock physics and geophysics, e.g. a simple case would be to convert the electrical conductivities to the log-scale.

## Functionalities

  - `stochastic_inverse` : perform Bayesian inference. Outputs the posterior distribution in the form of `MCMCChains`, which can be converted into a list of corresponding models using `get_model_list`.
