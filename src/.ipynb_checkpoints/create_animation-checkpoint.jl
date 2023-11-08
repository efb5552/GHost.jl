# """
# `create_animation(n,num_steps,step_size,m_min,m_max,M_host,R_host,r_min,r_max,V_initial,output_rate,fps,seed,parallel)`

# Runs most all functions within GHost to generate a final animation of the N-body simulation.

# # Arguments
# - n (Int): Number of particles around host
# - num_steps (Int): Number of time steps to resolve
# - step_size (Real): Time step in days.
# - m_min (Real): Minimum particle mass in kg. 
# - m_max (Real): Maximum particle mass in kg. 
# - M_host (BigFloat): Mass of host in kg. Note that this MUST be a BigFloat to avoid overflow errors. 
# - R_host (BigFloat): Radius of host in m. Note that this MUST be a BigFloat to avoid overflow errors. 
# - r_min (Real): Minimum radial distance from the center of the host that particles' initial coniditions can be placed (in units of host radii, and must be > 1.)
# - r_max (Real): Maximum radial distance from the center of the host that particles' initial coniditions can be placed (in units of host radii, and must be > 1.)
# - V_initial (Real): Fraction of minimum orbital velocity for particles.
# - output_rate (Int): Output every i'th frame of the final animation (saves on some computation, in addition to making the animation to speed up without having to watch it very slowly)
# - fps (Int): Frames per second rate of final animation (default 30 fps).
# - seed (Int): Random seed to populate initial conditions.
# - parallel (Bool): Optional parameter to indicate the functions to be run in parallel. 

# # Returns
# - Animation of the name "figures/GHost_anim_n$(n)_t$(num_steps)_dt$(step_size).gif"

# # Dependencies
# - `create_masses.jl`:Populates distribution of particle masses.
# - `initital_conditions.jl`: Populates initial conditions.
# - `orbit_matrix.jl`: Creates table of particle conditions at each timestep.
# - `animate_movements.jl`: Creates final animation.
# """

function create_animation(
        n::Int, # number of dust particles (Int)
        num_steps::Int, # Int
        step_size::Real, #days
        m_min::Real, # kg
        m_max::Real, # kg
        M_host::BigFloat, # kg
        R_host::BigFloat, # m
        r_min::Real, # host radii (>1)
        r_max::Real, # host radii (>r_min)
        V_initial::Real = 1., # fraction of minimum orbital speed,
        output_rate::Int = 1,
        fps::Int = 30,
        seed = nothing,
        parallel::Bool=false, # determines if program runs in parallel
        memory::String="Shared" # or "Distributed"
        )

    @assert 0. < m_min < m_max < M_host
    @assert r_max > r_min > 1.
    @assert seed > 0
    @assert num_steps > 0
    @assert step_size > 0.
    @assert R_host > 0.
    @assert V_initial > 0.
    @assert fps > 0
    @assert output_rate > 0
    @assert n > 0
    @assert memory in ["Shared", "Distributed"]
    
    # converting particle masses to fractions of host mass
    m_min = m_min/M_host
    m_max = m_max/M_host

    #creating tags for file name
    M_host_name = GHost.tag(M_host)
    R_host_name = GHost.tag(R_host)
    mmin_name = GHost.tag(m_min)
    mmax_name = GHost.tag(m_max)
    
    m = GHost.create_masses(n,m_min,m_max,seed)
    R,V = GHost.initial_conditions(m,r_min,r_max,M_host,R_host,V_initial) # position and velocity initial conditions
    orbits = GHost.orbit_matrix(m,R,V,num_steps,step_size,M_host,R_host,parallel,memory) # orbits is our major data table for particle conditions at each time step
    GHost.animate_movements(m,orbits,r_min,r_max,mmin_name,mmax_name,M_host_name,R_host_name,num_steps,seed,step_size,fps,output_rate) # create animation
    
end
export create_animation