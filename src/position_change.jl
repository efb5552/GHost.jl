"""
`position_change(index,R,V,A,step_size)`

# Arguments
- `index`: Column index for `R`, `V`, and `A`. `index`=1 for X positions/velocities/accelerations, `index`=2 for Y positions/velocities/accelerations.
- `R`: Matrix of current particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `V`: Matrix of current particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components.
- `A`: `n`x2 size matrix of net accelerations in the X and Y directions on each particle.
- `step_size`: Size of time steps in days (Type `Real`, must be greater than 0).

# Returns
- `pos`: Position vector of length `n` in units of planetary radii for the index of interest (X or Y). 

"""

function position_change(
        index::Int,
        R::Matrix,
        V::Matrix,
        A::Matrix,
        step_size::Real
    )
    
    @assert index == 1 || index == 2
    @assert size(R) == size(V) == size(A)
    @assert step_size > 0.
    
	pos = V[:,index].*step_size .+ (1/2).*A[:,index].*(step_size^2) .+ R[:,index] # calculating updated position
	return pos
end
export position_change