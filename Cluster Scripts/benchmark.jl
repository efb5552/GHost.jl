@everywhere include("../src/GHost.jl")

function benchmark(n_test,num_steps_test,M_planet_test,R_planet_test)

    # n_test = 10 #number of particles to test
    # num_steps_test = 1 # number of steps
    # M_planet_test = 1e10
    # R_planet_test = 1e5
    
    m_test = GHost.create_masses(n_test,10^(-20),10^(-10))
    R_test,V_test = GHost.initial_conditions(m_test,2,3,1e26,1e6,1.)
    A_test = GHost.acceleration(m_test,R_test,M_planet_test,R_planet_test)

    println("create_masses (n=$n_test,t=$num_steps_test):")
    @time GHost.create_masses(n_test,10^(-20),10^(-10))
    println("initial_conditions (n=$n_test,t=$num_steps_test):")
    @time GHost.initial_conditions(m_test,2,3,1e26,1e6,1.)
    println("acceleration (n=$n_test,t=$num_steps_test):")
    @time GHost.acceleration(m_test,R_test,M_planet_test,R_planet_test)
    println("position_change (n=$n_test,t=$num_steps_test):")
    @time GHost.position_change(1,R_test,V_test,A_test,0.0001)
    println("velocity_change (n=$n_test,t=$num_steps_test):")
    @time GHost.velocity_change(1,V_test,A_test,0.0001)
    println("move_particle (n=$n_test,t=$num_steps_test):")
    @time GHost.move_particle(m_test,R_test,V_test,0.0001,M_planet_test,R_planet_test)
    println("orbit_matrix (n=$n_test,t=$num_steps_test):")
    @time GHost.orbit_matrix(m_test,R_test,V_test,num_steps_test,0.0001,M_planet_test,R_planet_test)
end