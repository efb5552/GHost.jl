"""
`acceleration(m,R,M_host,R_host,)`

Calculate the total acceleration (in cartesian units) that is acting on an individual particle within a set of particles with given masses and positions.
It is assumed that the particles are revolving around a Saturn-like planet at the origin. 

# Arguments
- `m`: Array of particle masses of length `n` in units of planetary masses (type = `Float64`)
- `R`: Matrix of particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `M_host` (Real > 0): Mass of planetary body in kg.
- `R_host` (Real > 0): Radius of planetary body in m. 


# Returns
- `A`: `n`x2 size matrix of net accelerations in the X and Y directions on each particle.

# Dependencies
- `pythagoras.jl`: Determines the radial distance between two particles
"""

using ThreadsX
using SharedArrays
using Distributed

function acceleration_loop( # inner loop for the acceleration calculation (can be parallelized or not)
        m::Vector,
        x::Vector,
        y::Vector,
        r::Vector,
        i::Int, # index
        G::Real,
        A, #can be a a matrix (shared memory) or shared array (distributed memory)
    )        
    
    if r[i] > 1 # the following calculation only applies for particles that have not fallen into the planet's atmosphere
        
        @inbounds a_tot_x = -G*x[i]/(r[i]^3) # accel from host in x direction
        @inbounds a_tot_y = -G*y[i]/(r[i]^3) # accel from host in y direction

        for j in 1:length(m)
            if i != j # making sure not to count acceleration of particle on itself
                @inbounds Δx = x[j]-x[i]
                @inbounds Δy = x[j]-x[i]
                Δr = pythagoras(Δx,Δy)
                @inbounds a_tot_x += -G*m[j]*Δx/(Δr^3) # acceleration from j'th particle in the x direction
                @inbounds a_tot_y += -G*m[j]*Δy/(Δr^3) # acceleration from j'th particle in the y direction
            end
        end
        A[i,:] = [a_tot_x a_tot_y]
    else
        A[i,:] = [0. 0.] # if the particle falls in, it's acceleration is 0, and will stay that way.
    end
    return A
end
export acceleration_loop

function acceleration(
        m::Vector,
        R::Matrix,
        M_host::BigFloat,
        R_host::BigFloat,
        parallel::Bool=false,
        memory::String="Shared" # or "Distributed"
    )

    @assert M_host > 0
    @assert maximum(m) < 1 # making sure the masses aren't larger than the host planet)
    @assert R_host > 0
    @assert length(m) == size(R)[1] # m and R have the same lengths (every particle has a mass and a X-Y position)
    @assert size(R)[2] == 2 # every row of R has an X and Y position (width = 2)
    @assert memory in ["Shared", "Distributed"]
    
	G = grav_const(M_host,R_host) #gravitational constant in host radii^3 host masses^-1 days^-2 
	x = R[:,1]
	y = R[:,2]
	r = pythagoras(x,y) # returns vector of particle distances from the origin

    if parallel == false # serial loop
        A = zeros(length(m),2)
    	for i in 1:length(m)
    		A = acceleration_loop(m,x,y,r,i,G,A)
        end
    elseif parallel == true && memory == "Shared" # parallelized loop shared memory
        A = zeros(length(m),2)
        @sync ThreadsX.foreach(eachindex(m)) do i
            A = acceleration_loop(m,x,y,r,i,G,A)
        end
    elseif parallel == true && memory == "Distributed"
        A = SharedArray(zeros(length(m),2))
        @sync @distributed for i in 1:length(m)
    		A = acceleration_loop(m,x,y,r,i,G,A)
        end
    end

    # deallocating memory
    x = 0
    y = 0
    r = 0
    
	return A
end
export acceleration