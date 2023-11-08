"""
`initial_conditions(m,r_min,r_max)`

# Arguments
- `m`: Vector of particle masses of length `n` in units of planetary masses (type = `Float64`)
- `r_min`: Minimum initial radial position of particles from the center of the planetary body in units of planetary radii (must be greater than 1)
- `r_max`: Maximum initial radial position of particles from the center of the planetary body in units of planetary radii (must be greater than `r_min`).
- `M_planet_log` (Real > 0): Mass of planetary body in kg.
- `R_planet` (Real > 0): Radius of planetary body in m. 
- `V_initial` (Real >= 0): Fraction of initial orbital speed. Setting this to 1 is setting the initital speed to the minimum tangential velocity to maintian the orbit.

# Returns
- `R`: Matrix of initial particle positions of size `n`x2 in units of planetary radii. The first column is X positions for each particle and the second column is Y positions. 
- `V`: Matrix of initial particle velocity components of size `n`x2 in units of planetary radii per day. The first column is X velocity components for each particle and the second column is Y components. 

#Dependencies
- `grav_const.jl`: Calculates a usable version of the gravitational constant to avoid numerical issues.

"""

using Random, Distributions

function initial_conditions(
        m::Vector,
        r_min::Real,
        r_max::Real,
        M_planet::BigFloat,
        R_planet::BigFloat,
        V_initial::Real=1.,
        seed=missing
    )

    @assert r_max > r_min > 1.
    @assert M_planet > 0
    @assert maximum(m) < 1 # making sure the particle masses aren't larger than the host 
    @assert R_planet > 0
    @assert V_initial >= 0

    if isdefined(seed,:Int)
        Random.seed!(seed) # sets random seed for initial conditions.
    end
    
	G = grav_const(M_planet,R_planet) #gravitational constant in planet radii^3 planet masses^-1 days^-2
	M_planet = 1.
	n = length(m)

	ϕ = zeros(Float64,n)
	r = zeros(Float64,n)
	x = zeros(Float64,n)
	y = zeros(Float64,n)

    # initial polar coordinates
	ϕ = rand(Uniform(0,2*π),n) # random azimuthal degree for each particle in radians
	r = rand(Uniform(r_min,r_max),n) # random radial distance each particle in units of planetary radii
	
	# converting from polar to cartesian
	x = r.*cos.(ϕ) 
	y = r.*sin.(ϕ)
	R = [x y] #initial positions matrix

	V_rad = V_initial*((G./(r)).^(0.5)) # minimum velocity to stay in orbit
	V = [-V_rad.*sin.(ϕ) V_rad.*cos.(ϕ)] # 2d array of x and y components of initial velocites

	return R,V
end
export initial_conditions