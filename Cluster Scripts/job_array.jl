using Distributed 
@everywhere using ParallelUtilities

@everywhere include("../src/GHost.jl")
# @everywhere using .GHost

@everywhere function process(n,t,dt,parallel)
    n = 100
    t = 100
    dt = 0.001
    parallel = false
    M_host = 5.6*big(10)^26 # kg, overflow is a big issue here, make sure to specify it as 
    R_host = 5.82*big(10)^7 # m
    # M_host = big(10.)^26 # kg, overflow is a big issue here, make sure to specify it as 
    # R_host = 2*big(10.)^7 # m

    r_min = 2.0 # planetary radii (>1)
    r_max = 6.0 # planetary radii (>r_min)
    m_min = 10^(-20) # kg
    m_max = 10^(-10) # kg
    V_initial = 1. # fraction of minimum orbital speed
    num_steps = 50 # Int
    step_size = 0.001 #days
    fps = 30
    output_rate = 1 # only plot evey i'th time step
    seed = 1234

    GHost.create_animation(
        n, # number of dust particles (Int)
        t, # Int
        dt, #days
        m_min, # kg
        m_max, # kg
        M_host, # kg
        R_host, # m
        r_min, # host radii (>1)
        r_max, # host radii (>r_min)
        V_initial,
        output_rate,
        fps,
        seed,
        parallel
        )
end

n = 10_000_000;
n_per_worker = round(Int64,n//nworkers())
n_actual = n_per_worker * nworkers()
pmapreduce(calc_pi, +, fill(1, nworkers()) ) / nworkers()
@time pi_estimate = pmapreduce(calc_pi, +, fill(n_per_worker, nworkers()) ) / nworkers()
println("# After ", n_per_worker, " itterations on each of ", nworkers(), " workers, estimated pi to be...")
println(pi_estimate)