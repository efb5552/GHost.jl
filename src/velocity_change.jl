"""
`velocity_change(index,V,A,step_size)`

# Arguments
- `index`: Column index for `V`, and `A`. `index`=1 for X velocities/accelerations, `index`=2 for Y velocities/accelerations.
- `V`: Matrix of current particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components.
- `A`: `n`x2 size matrix of net accelerations in the X and Y directions on each particle.
- `step_size`: Size of time steps in days (Type `Real`, must be greater than 0).

# Returns
- `v`: Velocity vector of length `n` in units of planetary radii for the cartesian component of interest (X or Y). 

"""

function velocity_change(
        index::Int,
        V::Matrix,
        A::Matrix,
        step_size::Real
    )

    @assert index == 1 || index == 2
    @assert size(V) == size(A)
    @assert step_size > 0.
    
	v =  V[:,index] .+ step_size.*A[:,index]
	return v
end
export velocity_change