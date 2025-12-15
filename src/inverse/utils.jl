do_verbose(iter::Int, verbose::Bool) = verbose # COV_EXCL_LINE
do_verbose(verbose::Bool) = verbose # COV_EXCL_LINE
do_verbose(iter::Int, verbose::Int) = (iter % verbose == 0) # COV_EXCL_LINE
