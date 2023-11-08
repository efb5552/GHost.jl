"""
`energy_arrays(m,orbits,num_steps)`

Create arrays of system kinetic and potential energies for every time step. 

# Arguments
- `m`: Array of particle masses of length `n` in units of planetary masses (type = `Float64`)
- `orbits`: Matrix of particle positions (planetary radii) and velocity components (planet radii per day) for every time step of size `n`x4`num_steps+4`. Each column is notated by either "Rx_i", "Ry_i", Vx_i", or "vy_i" where "i" is the time step index.
- `num_steps`: Number of time steps (type `Int`)

# Returns
- `K`: Vector of kinetic energies of length `num_steps` in units of planetary masses planetary radii^2 days^-2
- `U`: Vector of gravitational potential energies of length `num_steps` in units of planetary masses planetary radii^2 days^-2

# Dependencies
- `system_energy.jl`: Calculates kinetic and gravitational potential energy at a given time step.
"""

# include("system_energy.jl")

function energy_arrays(
        m::Vector,
        orbits::DataFrames.DataFrame,
        num_steps::Int,
        M_planet::Real,
        R_planet::Real,
        parallel::Bool=false
    )

    @assert size(orbits)[1] == length(m)
    @assert size(orbits)[2] == 4*(num_steps+1) 
    @assert num_steps > 0
    @assert M_planet > 0
    @assert R_planet > 0
    
	K = zeros(Float64,0)
	U = zeros(Float64,0)
	for i in range(0,num_steps) # iterating over all time steps
		R_temp = [orbits[:,"Rx_$i"] orbits[:,"Ry_$i"]]
		V_temp = [orbits[:,"Vx_$i"] orbits[:,"Vy_$i"]]
		K_temp, U_temp = system_energy(m,R_temp,V_temp,M_planet,R_planet,parallel) # calculating energies for a time step
		push!(K,K_temp) # pushing total kinetic energy for a time step to the parent array
		push!(U,U_temp) # pushing total potential energy for a time step to the parent array
	end
	return K, U
end
export energy_arrays