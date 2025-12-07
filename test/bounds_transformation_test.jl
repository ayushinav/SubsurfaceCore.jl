@testitem "bounds transformation tests" tags = [:transformation] begin
    using Test
    x = randn(20)
    m = sigmoid_tf.tf.(10 .* x)
    @test all(-3.0 .<= m .<= 6.0)
    @test all(.≈(sigmoid_tf.itf.(m), 10 .* x, atol = 1e-2))

    m = pow_tf.tf.(x)
    @test all(m .≈ exp10.(x))
    @test all(pow_tf.itf.(m) .≈ x)


    m = log_tf.tf.(1 .+ abs(minimum(x)) .+ x)
    @test all(m .≈ log10.(1 .+ abs(minimum(x)) .+ x))
    @test all(log_tf.itf.(m) .≈ (1 .+ abs(minimum(x)) .+ x))


    m = pow_sigmoid_tf.tf.(10 .* x)
    @test all(1e-3 .<= m .<= 1e6)
    @test all(pow_sigmoid_tf.itf.(m) .≈ 10 .* x)

    m = lin_tf.tf.(x)
    @test all(m .≈ identity.(x))
    @test all(lin_tf.itf.(m) .≈ x)

    m = phi_scale_tf.tf.(x)
    @test all(m .≈ x ./ 90)
    @test all(phi_scale_tf.itf.(m) .≈ x)
end
