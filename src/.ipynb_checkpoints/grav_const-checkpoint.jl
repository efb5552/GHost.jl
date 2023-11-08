"""
`grav_const(M_planet,R_planet)`

Determines the gravitational constant in terms of planetary radii and planetary mass, and days. 

# Arguments
- `M_planet` (BigFloat > 0): Mass of planetary body in solar masses. Ensure it is a BigFloat type to avoid overflow.
- `R_planet` (BigFloat > 0): Radius of planetary body in m.  Ensure it is a BigFloat type to avoid overflow.

# Returns
- `G`: Gravitational constant of units (planetary radii)^3 (planetary masses)^-1 (days)^-2.

"""

function grav_const(
        M_host::BigFloat,
        R_host::BigFloat
    )

    @assert M_host > 0 # make sure to use big() notation to prevent overflow!
    @assert R_host > 0 # make sure to use big() notation to prevent overflow!
    
    G = (6.6738*10^(-11))*(86400^2) # converting G from s^-2 to days^-2
    G = G*(R_host)^(-3)*(M_host) # converting G from kg m^-3 to host mass host radii^-3

	return G
end
export grav_const