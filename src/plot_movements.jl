"""
`plot_movements(m,R,V,r_min,r_max,step,step_size)`

Create a plot with calculated particle positions and velocities for a given time step.

# Arguments
- `m`: Vector of `n` particle masses in planetary masses
- `R`: Matrix of current particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `V`: Matrix of current particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components. 
- `step_size`: Size of time steps in days (Type `Real`, must be greater than or equal to 0).
- `step_index`: The current step in which the plot is considered (used to calculate how much time has passed). The maximum value is equivalent to `num_steps` (total number of time steps).

# Returns
- Plot of current particle positions and current velocity vectors.

# Dependencies
- `pythagoras.jl`: Determines the radial distance between two particles
"""

# include("pythagoras.jl")

function plot_movements(
        m::Vector,
        R::Matrix,
        V::Matrix,
        r_min::Real,
        r_max::Real,
        step_size::Real,
        step_index::Int
    )

    @assert length(m) == size(R)[1] == size(V)[1]
    @assert size(R)[2] == size(V)[2] == 2
    @assert r_max > r_min > 1.
    @assert step_size > 0.
    @assert step_index >= 0
    
	# n = length(m)
	R_planet = 1.

    # plotting particle positions
	scatter(R[:,1], R[:,2],
		markersize= 1 .+ 3 .*(m .- minimum(m))./(maximum(m)-minimum(m)), # relative particle masses for visual aid
		color=:gray,
		markerstrokecolor = "white",
		legend=false,
		title="Hours: $(floor(Int,round(step_index*step_size*24))) (Step # $step_index)",
		aspectratio= :equal,
        xlabel = "X Position (Host Radii)",
        ylabel = "Y Position (Host Radii)",
	)

    # Central marker for planet (roughly matches 1 planetary radii) 
	scatter!([0],[0],markersize=20,color=:orange)

    #plotting velocity vectors
	for i in 1:length(m)
		if pythagoras(R[i,1], R[i,2]) > R_planet # not plotting vectors for particles that have fallen into planet
    		plot!([R[i,1] ; (R[i,1]+ 0.01*V[i,1])],[R[i,2] ; (R[i,2]+0.01*V[i,2])],
    			legend = false,
    			color=:gray
    		)
    	end
	end
    
	xlims!(-10,10)
	ylims!(-10,10)
end
export plot_movements