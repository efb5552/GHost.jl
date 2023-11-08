"""
`display_initial_conditions(m,R,V)`

Graphically display/plot the initial conditions of the system as particles surrounding a central planetary body.

# Arguments
- `m`: Array of particle masses of length `n` in units of planetary masses (type = `Float64`)
- `R`: Matrix of initial particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `V`: Matrix of initial particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components. 

# Returns
- Plot of particle positions and velocity vectors.
"""
function display_initial_conditions(
        m::Vector,
        R::Matrix,
        V::Matrix,
    )

    @assert length(m) == size(R)[1] == size(V)[1]
    @assert size(R)[2] == size(V)[2] == 2

    # plotting particles
	scatter(R[:,1],R[:,2],
		markersize= 1 .+ 3 .*(m .- minimum(m))./(maximum(m)-minimum(m)), #relative particle size visual aid
		color=:gray,
		markerstrokecolor = "white",
		reuse = false,
        aspectratio= :equal,
	)
    
    #plotting velocity vectors
	for i in 1:length(m)
		plot!([R[i,1] ; (R[i,1]+ 0.01*V[i,1])],[R[i,2] ; (R[i,2]+0.01*V[i,2])],
			legend = false,
			color=:gray
		)
	end
    
	xlims!(-10,10)
	ylims!(-10,10)
    
end
export display_initial_conditions