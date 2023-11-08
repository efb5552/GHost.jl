"""
`animate_movements(orbits,m,r_min,r_max,num_steps,step_size,fps,output_rate)`

Animate the movements of `n` particles around a planetary body using previously calculated orbital positions and velocities 

# Arguments
- `m`: Vector of `n` particle masses in planetary masses
- `orbits`: Matrix of particle positions and velocities for every time step of size `n`x4`num_steps`. Each column is notated by either "Rx_i", "Ry_i", Vx_i", or "vy_i" where "i" is the time step index.
- `r_min`: Minimum initial radial position of particles from the center of the planetary body in units of planetary radii
- `r_max`: Maximum initial radial position of particles from the center of the planetary body in units of planetary radii
- `M_host` (Real > 0): Mass of planetary body in kg.
- `R_host` (Real > 0): Radius of planetary body in m
- `num_steps`: Number of time steps (type `Int`)
- `step_size`: Size of time steps in days (Type `Real`)
- `fps`: Frames per second of output animation (must be greater than 0)
- `output_rate`: Output an image for the animation every `k`th iteration (must be greater than or equal to 1)

# Returns
- Outputted animation of particle orbits saved to the "/tmp/" directory.

# Dependencies
- `plot_movements.jl`: Plots each frame of the animation
"""

# include("plot_movements.jl")

using Plots

function animate_movements(
        m::Vector,
        orbits::DataFrames.DataFrame,
        r_min::Real,
        r_max::Real,
        mmin_name::String,
        mmax_name::String,
        M_host_name::String,
        R_host_name::String,
        num_steps::Int,
        seed::Int,
        step_size::Real,
        fps::Int=30,
        output_rate::Int=1
    )

    @assert size(orbits)[1] == length(m)
    @assert size(orbits)[2] == 4*(num_steps+1) 
    @assert r_max > r_min > 0.
    @assert step_size > 0.
    @assert fps > 0
    @assert output_rate >= 1
    
	anim = @animate for i in range(0,num_steps)
		R_temp = [orbits[:,"Rx_$i"] orbits[:,"Ry_$i"]]
		V_temp = [orbits[:,"Vx_$i"] orbits[:,"Vy_$i"]]
	    plot_movements(m,R_temp,V_temp,r_min,r_max,step_size,i)
        # deallocating memory
        R_temp = 0
        V_temp = 0
	end every output_rate
	gif(anim, "figures/GHost_anim_n$(length(m))_t$(num_steps)_dt$(step_size)_seed$(seed)_mmin$(mmin_name)_mmax$(mmax_name)_rmin$(r_min)_rmax$(r_max)_MHost$(M_host_name)_RHost$(R_host_name).gif",fps=fps)
end
export animate_movements