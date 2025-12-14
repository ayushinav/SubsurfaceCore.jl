@testitem "bounds transformation : accuracy" tags = [:transformation] begin
    x = randn(100)

    m = sigmoid_tf.tf.(10 .* x)
    @test all(-3.0 .<= m .<= 6.0)
    @test all(.≈(sigmoid_tf.itf.(m), 10 .* x))

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

    # ==
    my_scale_tf = transform_utils(x -> scale_fn(x, 10), x -> inverse_scale_fn(x, 10))
    m = my_scale_tf.tf.(x)
    @test all(m .≈ x ./ 10)
    @test all(my_scale_tf.itf.(m) .≈ x)
end

@testitem "bounds transformation : allocations" tags = [:transformation] begin
    function bench_tf(tf, x)
        broadcast!(tf.tf, x, x)
        return nothing
    end

    function bench_itf(tf, x)
        broadcast!(tf.itf, x, x)
        return nothing
    end

    x = randn(100)

    m = sigmoid_tf.tf.(10 .* x)
    bench_itf(sigmoid_tf, m)
    bench_tf(sigmoid_tf, m)
    alloc_ = @allocated bench_itf(sigmoid_tf, m)
    @test alloc_ == 0
    alloc_ = @allocated bench_tf(sigmoid_tf, m)
    @test alloc_ == 0

    m = pow_tf.tf.(x)
    bench_itf(pow_tf, m)
    bench_tf(pow_tf, m)
    alloc_ = @allocated bench_itf(pow_tf, m)
    @test alloc_ == 0
    alloc_ = @allocated bench_tf(pow_tf, m)
    @test alloc_ == 0

    m = log_tf.tf.(1 .+ abs(minimum(x)) .+ x)
    bench_itf(log_tf, m)
    bench_tf(log_tf, m)
    alloc_ = @allocated bench_itf(log_tf, m)
    @test alloc_ == 0
    alloc_ = @allocated bench_tf(log_tf, m)
    @test alloc_ == 0

    m = pow_sigmoid_tf.tf.(10 .* x)
    bench_itf(pow_sigmoid_tf, m)
    bench_tf(pow_sigmoid_tf, m)
    alloc_ = @allocated bench_itf(pow_sigmoid_tf, m)
    @test alloc_ == 0
    alloc_ = @allocated bench_tf(pow_sigmoid_tf, m)
    @test alloc_ == 0

    m = lin_tf.tf.(x)
    bench_itf(lin_tf, m)
    bench_tf(lin_tf, m)
    alloc_ = @allocated bench_itf(lin_tf, m)
    @test alloc_ == 0
    alloc_ = @allocated bench_tf(lin_tf, m)
    @test alloc_ == 0

    # ==
    my_scale_tf = transform_utils(x -> scale_fn(x, 10), x -> inverse_scale_fn(x, 10))
    m = my_scale_tf.tf.(x)
    bench_itf(my_scale_tf, m)
    bench_tf(my_scale_tf, m)
    alloc_ = @allocated bench_itf(my_scale_tf, m)
    @test alloc_ == 0
    alloc_ = @allocated bench_tf(my_scale_tf, m)
    @test alloc_ == 0
end

@testitem "bounds transformation : type inference" tags = [:transformation] begin
    using JET
    function bench_tf(tf, x)
        broadcast!(tf.tf, x, x)
        return nothing
    end

    function bench_itf(tf, x)
        broadcast!(tf.itf, x, x)
        return nothing
    end

    x = randn(100)

    m = sigmoid_tf.tf.(10 .* x)
    @test_opt bench_tf(sigmoid_tf, m)
    @test_opt bench_itf(sigmoid_tf, m)

    m = pow_tf.tf.(x)
    @test_opt bench_tf(pow_tf, m)
    @test_opt bench_itf(pow_tf, m)

    m = log_tf.tf.(1 .+ abs(minimum(x)) .+ x)
    @test_opt bench_tf(log_tf, m)
    @test_opt bench_itf(log_tf, m)

    m = pow_sigmoid_tf.tf.(10 .* x)
    @test_opt bench_tf(pow_sigmoid_tf, m)
    @test_opt bench_itf(pow_sigmoid_tf, m)

    m = lin_tf.tf.(x)
    @test_opt bench_tf(lin_tf, m)
    @test_opt bench_itf(lin_tf, m)

    # ==
    my_scale_tf = transform_utils(x -> scale_fn(x, 10), x -> inverse_scale_fn(x, 10))
    m = my_scale_tf.tf.(x)
    @test_opt bench_tf(my_scale_tf, m)
    @test_opt bench_itf(my_scale_tf, m)
end
