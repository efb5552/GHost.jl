"""
`move_particle(m,R,V,step_size)`

Determines updated particle positions and velocity components after a time `step_size` in days has passed within a gravitational field of other particles and a planetary body.

# Arguments
- `m`: Vector of particle masses of length `n` in units of planetary masses (type = `Float64`)
- `R`: Matrix of initial particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `V`: Matrix of initial particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components. 
- `step_size`: Size of time steps in days (Type `Real`, must be greater than 0).
- `M_planet` (Real > 0): Mass of planetary body in kg.
- `R_planet` (Real > 0): Radius of planetary body in m. 

# Returns
- `R_new`: Matrix of updated particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `V_new`: Matrix of updated particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components. 

# Dependencies
- `pythagoras.jl`: Determines the radial distance between two particles.
- `acceleration.jl`: Determines the net components of the acceleration acted upon a particle due to gravity.
- `position_change.jl`: Determines the change in position for a particle due to some acceleration.
- `velocity_change.jl`: Determines the change in velocity for a particle due to some acceleration.
"""

function move_particle(
        m::Vector,
        R::Matrix,
        V::Matrix,
        step_size::Real,
        M_host::BigFloat,
        R_host::BigFloat,
        parallel::Bool=false,
        memory::String="Shared" # or "Distributed"
    )

    @assert length(m) == size(R)[1] == size(V)[1]
    @assert size(R)[2] == size(V)[2] == 2
    @assert step_size > 0.
    @assert M_host > 0.
    @assert R_host > 0.
    @assert memory in ["Shared", "Distributed"]

    # determine net acceleration components for each particle
    A = acceleration(m,R,M_host,R_host,parallel,memory)
    A = Matrix(A)

    # determine position changes
	x = position_change(1,R,V,A,step_size)
	y = position_change(2,R,V,A,step_size)

    # determine velocity changes
	v_x = velocity_change(1,V,A,step_size)
	v_y = velocity_change(2,V,A,step_size)

    # deallocating acceleration array 
    A = 0

    # account for particles that have fallen into the planet, set position and velocities as 0.
	for i in 1:length(m)
		r = pythagoras(x[i],y[i])
		if r <= 1.
			x[i] = 0
			y[i] = 0
			v_x[i] = 0.
			v_y[i] = 0.
		end
	end
	
	V_new = [v_x v_y]
	R_new = [x y]

    # deallocating position and velocity arrays 
    x = 0
    y = 0
    v_x = 0
    v_y = 0

	return R_new, V_new
end
export move_particle