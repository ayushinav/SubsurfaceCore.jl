"""
    `transform_utils(p, tf, itf, dtf)`

Contains the parameters and functions for transformation from optimization to model domains.

## Arguments

  - `tf` : function to convert from computational to model domain
  - `itf` : function to convert from model to computational domain

## Usage

Implementation of `pow_tf` : when computational domain = log10 (model domain)

```julia
transform_utils(exp10, log10)
```

Also checkout relevant documentation
"""

struct transform_utils{F1, F2}
    tf::F1
    itf::F2
end

"""
`sigmoid(m)`:
move to model domain from optimization domain using a sigmoid transformation
"""

function sigmoid(m, a, b)
    # return inv(1 + exp(-m / (bounds[2] - bounds[1]))) * (bounds[2] - bounds[1]) + bounds[1]
    return inv(one(m) + exp(-m / (b - a))) * (b - a) + a
end

function pow_sigmoid(m, a, b)
    return exp10(sigmoid(m, a, b))
end

"""
`inverse_sigmoid()`: get back to the optimization domain from model domain
"""
function inverse_sigmoid(m, a, b)
    # if x ≈ bounds[2] return 100 end
    # if x ≈ bounds[1] return -100 end
    # return (bounds[2] - bounds[1]) * (log(abs(x - bounds[1])) - log(abs(bounds[2] - x)))
    return (b - a) * (log(abs(m - a)) - log(abs(b - m)))
end

function inverse_pow_sigmoid(m, a, b)
    return inverse_sigmoid(log10(m), a, b)
end

#= 
should generally be good for most inversions
==============================================================
=#
"""
    sigmoid_tf

A [`transform_utils`](@ref) constant using `σ(x)` ; `σ(x) = 1 / (1 + exp(-x))` \n

  - computational domain to model domain : `m = -3 + 9σ(x)` \n
  - model domain to computational domain : `x = σ⁻¹((m+3)/9)` \n

The above bounds the model domain in [-3, 6], to bound the model parameters in a different domain [a,b] : \n
\n
`transform_utils(x -> sigmoid(x, (a, b)), x -> inverse_sigmoid(x, (a, b)));`
"""
const sigmoid_tf = transform_utils(
    x -> sigmoid(x, -3.0f0, 6.0f0), x -> inverse_sigmoid(x, -3.0f0, 6.0f0));

"""
    pow_tf

A [`transform_utils`](@ref) constant using `exp10` \n

  - computational domain to model domain : m = exp10(x) \n
  - model domain to computational domain : x = log10(m) \n
"""
const pow_tf = transform_utils(exp10, log10);

"""
    log_tf

A [`transform_utils`](@ref) constant using `log10` \n

  - computational domain to model domain : m = log10(x) \n
  - model domain to computational domain : x = exp10log10(m) \n
"""
const log_tf = transform_utils(log10, exp10);

"""
    pow_sigmoid_tf

A [`transform_utils`](@ref) constant similar to `sigmoid_tf`(@ref) but further performs `exp10` to convert into model domain \n

  - computational domain to model domain : `m = exp10(-3 + 9σ(x))` \n
  - model domain to computational domain : x` = σ⁻¹((log10(m)+3)/9)` \n

The above bounds the model domain in [10⁻³, 10⁶], to bound the model parameters in a different domain [10ᵃ,10ᵇ] : \n
\n
`transform_utils(x -> pow_sigmoid(x, (a, b)), x -> inverse_pow_sigmoid(x, (a, b)));`
"""
const pow_sigmoid_tf = transform_utils(
    x -> pow_sigmoid(x, -3.0f0, 6.0f0), x -> inverse_pow_sigmoid(x, -3.0f0, 6.0f0));

"""
    no_tf

A [`transform_utils`](@ref) constant that doesn't transform \n
Default `transform_utils` if nothing else is provided

  - computational domain to model domain : m = x \n
  - model domain to computational domain : x = m \n
"""
const no_tf = transform_utils(identity, identity);
