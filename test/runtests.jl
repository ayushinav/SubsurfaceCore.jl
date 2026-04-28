using Pkg

const GROUP = lowercase(get(ENV, "GROUP", "all"))

if GROUP == "turing"
    Pkg.activate(joinpath(@__DIR__, "turing"))
    Pkg.develop(PackageSpec(path=dirname(@__DIR__)))
    Pkg.instantiate()
elseif GROUP == "pigeons"
    Pkg.activate(joinpath(@__DIR__, "pigeons"))
    Pkg.develop(PackageSpec(path=dirname(@__DIR__)))
    Pkg.instantiate()
end

using ReTestItems, InteractiveUtils, Hwloc, SubsurfaceCore

@info sprint(versioninfo)

const RETESTITEMS_NWORKERS = parse(
    Int, get(ENV, "RETESTITEMS_NWORKERS", string(min(Hwloc.num_physical_cores(), 4))))
const RETESTITEMS_NWORKER_THREADS = parse(Int,
    get(ENV, "RETESTITEMS_NWORKER_THREADS",
        string(max(Hwloc.num_virtual_cores() ÷ RETESTITEMS_NWORKERS, 1))))

@info "Running tests with $(RETESTITEMS_NWORKERS) workers and \
       $(RETESTITEMS_NWORKER_THREADS) threads for group $(GROUP)"

ReTestItems.runtests(SubsurfaceCore; tags=(GROUP == "all" ? nothing : [Symbol(GROUP)]),
    nworkers=RETESTITEMS_NWORKERS,
    nworker_threads=RETESTITEMS_NWORKER_THREADS, testitem_timeout=3600)
