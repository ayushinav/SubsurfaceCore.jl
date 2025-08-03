do_verbose(iter::Int, verbose::Bool) = verbose
do_verbose(verbose::Bool) = verbose
do_verbose(iter::Int, verbose::Int) = (iter % verbose == 0)
