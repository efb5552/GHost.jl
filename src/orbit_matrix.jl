"""
`orbit_matrix(m,R,V,num_steps,step_size)`

Create a DataFrame object with all calculated particle positions and velocities for all time steps.

# Arguments
- `m`: Vector of `n` particle masses in planetary masses
- `R`: Matrix of initial particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `V`: Matrix of initial particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components. 
- `num_steps`: Number of time steps (type `Int`)
- `step_size`: Size of time steps in days (Type `Real`, must be greater than 0).
- `M_planet` (Real > 0): Mass of planetary body in kg.
- `R_planet` (Real > 0): Radius of planetary body in m. 

# Returns
- `orbits`: Matrix of particle positions and velocities for every time step of size `n`x4`num_steps`. Each column is notated by either "Rx_i", "Ry_i", Vx_i", or "vy_i" where "i" is the time step index.

# Dependencies
- `move_particle.jl`: Determines updated particle positions and velocity components after a time `step_size` in days has passed within a gravitational field of other particles and a planetary body.
"""

using DataFrames

function orbit_matrix(
        m::Vector,
        R::Matrix,
        V::Matrix,
        num_steps::Int,
        step_size::Real,
        M_planet::Real,
        R_planet::Real,
        parallel::Bool=false,
        memory::String="Shared" # or "Distributed"
    )

    @assert length(m) == size(R)[1] == size(V)[1]
    @assert size(R)[2] == size(V)[2] == 2
    @assert step_size > 0.
    @assert M_planet > 0.
    @assert R_planet > 0.
    @assert memory in ["Shared", "Distributed"]
    
	orbits = DataFrame(
		"Rx_0"=>R[:,1],
		"Ry_0"=>R[:,2],
		"Vx_0"=>V[:,1],
		"Vy_0"=>V[:,2]
	)

    for i in range(1,num_steps)
        R_temp = [orbits[:,"Rx_$(i-1)"] orbits[:,"Ry_$(i-1)"]]
        V_temp = [orbits[:,"Vx_$(i-1)"] orbits[:,"Vy_$(i-1)"]]
        R_new, V_new = move_particle(m,R_temp,V_temp,step_size,M_planet,R_planet,parallel,memory)
        orbits[!,"Rx_$i"] = R_new[:,1]
        orbits[!,"Ry_$i"] = R_new[:,2]
        orbits[!,"Vx_$i"] = V_new[:,1]
        orbits[!,"Vy_$i"] = V_new[:,2]
        R_temp = 0
        V_temp = 0
        R_new = 0
        V_new = 0
    end
	return orbits
end
export orbit_matrix