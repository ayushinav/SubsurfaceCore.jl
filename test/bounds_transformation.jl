@testitem "inverse tests" tags = [:transformation] begin
    x = randn(20)

    m = sigmoid_tf.tf.(100 .* x)
    @test -3 .< m .< 6
    @test sigmoid_tf.itf.(m) .≈ 100 .* x


    m = pow_tf.tf.(x)
    @test m .≈ exp10.(x)
    @test pow_tf.itf.(m) .≈ x


    m = log_tf.tf.(1 .+ abs(minimum(x)) .+ x)
    @test m .≈ log10.(1 .+ abs(minimum(x)) .+ x)
    @test log_tf.itf.(m) .≈ (1 .+ abs(minimum(x)) .+ x)


    m = pow_sigmoid_tf.tf.(10 .* x)
    @test 1e-3 .< m .< 1e6
    @test pow_sigmoid_tf.itf.(m) .≈ 10 .* x

    m = lin_tf.tf.(x)
    @test m .≈ identity.(x)
    @test lin_tf.itf.(m) .≈ x

    m = phi_scale_tf.tf.(x)
    @test m .≈ x ./ 90
    @test phi_scale_tf.itf.(m) .≈ x
end
