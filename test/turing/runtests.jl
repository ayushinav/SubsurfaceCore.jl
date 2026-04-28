using Pkg
Pkg.instantiate()

using ReTestItems, InteractiveUtils, Hwloc, SubsurfaceCore

@info sprint(versioninfo)

const RETESTITEMS_NWORKERS = parse(
    Int, get(ENV, "RETESTITEMS_NWORKERS", string(min(Hwloc.num_physical_cores(), 4))))
const RETESTITEMS_NWORKER_THREADS = parse(Int,
    get(ENV, "RETESTITEMS_NWORKER_THREADS",
        string(max(Hwloc.num_virtual_cores() ÷ RETESTITEMS_NWORKERS, 1))))

ReTestItems.runtests(
    joinpath(@__DIR__, "mcmc_test.jl"); tags=[:turing], nworkers=RETESTITEMS_NWORKERS,
    nworker_threads=RETESTITEMS_NWORKER_THREADS, testitem_timeout=3600)
