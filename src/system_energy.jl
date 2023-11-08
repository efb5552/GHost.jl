"""
`system_energy(m,R,V)`

Determines total kinetic and gravitational potential energies of a system of particles with known masses, velocities, and positions relative to each other and a planetary body.

# Arguments
- `m`: Vector of particle masses of length `n` in units of planetary masses (type = `Float64`)
- `R`: Matrix of initial particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `V`: Matrix of initial particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components. 
- `M_planet_log` (Real > 0): Mass of planetary body in log(kg). For large planets, the `log()` helps to reduce some errors.
- `R_planet` (Real > 0): Radius of planetary body in m. 

# Returns
- `K`: Value of kinetic energy in units of planetary masses planetary radii^2 days^-2
- `U`: Value of  gravitational potential energy in units of planetary masses planetary radii^2 days^-2

# Dependencies
- `pythagoras.jl`: Determines the radial velocity for a particle.
"""

# include("pythagoras.jl")
using ThreadsX

function system_energy(
        m::Vector,
        R::Matrix,
        V::Matrix,
        M_planet::Real,
        R_planet::Real,
        parallel::Bool=false
    )

    @assert length(m) == size(R)[1] == size(V)[1]
    @assert size(R)[2] == size(V)[2] == 2
    @assert M_planet > 0
    @assert R_planet > 0
    
	# n = length(m)
	G = grav_const(M_planet,R_planet) #gravitational constant in planet radii^3 planet masses^-1 days^-2 (specific to saturn)
	
	K = sum(1.0.*m.*pythagoras(V[:,1],V[:,2]).^2) # kinetic energy
	
	U = zeros(0)
	r_host = pythagoras(R[:,1],R[:,2])

    if parallel == true
    	for i in 1:length(m)
    		U_p = zeros(Float64,0)
    		push!(U_p, G*m[i]*1/r_host[i])
    		for j in 1:length(m)
    			if i != j
    				r_ij = pythagoras(abs(R[i,1]-R[j,1]),abs(R[i,2]-R[j,2]))
    				push!(U_p,G*m[i]*m[j]/r_ij)
    			end
    		end
    		push!(U,sum(U_p))
    	end
    else
        @sync ThreadsX.foreach(eachindex(m)) do i
            U_p = zeros(Float64,0)
    		push!(U_p, G*m[i]*1/r_host[i])
    		for j in 1:length(m)
    			if i != j
    				r_ij = pythagoras(abs(R[i,1]-R[j,1]),abs(R[i,2]-R[j,2]))
    				push!(U_p,G*m[i]*m[j]/r_ij)
    			end
    		end
    		push!(U,sum(U_p))
    	end
    end
	U = sum(U)
	return K,U
end
export system_energy