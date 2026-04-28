using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(PackageSpec(; path=joinpath(@__DIR__, "../..")))
Pkg.instantiate()

using ReTestItems, InteractiveUtils, Hwloc, SubsurfaceCore

@info sprint(versioninfo)

const RETESTITEMS_NWORKERS = parse(
    Int, get(ENV, "RETESTITEMS_NWORKERS", string(min(Hwloc.num_physical_cores(), 4))))
const RETESTITEMS_NWORKER_THREADS = parse(Int,
    get(ENV, "RETESTITEMS_NWORKER_THREADS",
        string(max(Hwloc.num_virtual_cores() ÷ RETESTITEMS_NWORKERS, 1))))

ReTestItems.runtests(@__DIR__; tags=[:pigeons], nworkers=RETESTITEMS_NWORKERS,
    nworker_threads=RETESTITEMS_NWORKER_THREADS, testitem_timeout=3600)
