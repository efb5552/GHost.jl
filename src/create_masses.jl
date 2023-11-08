"""
`create_masses(n,m_min,m_max,ξ)`

Create a random array of `n` dust particles with a minimum mass of `m_min` and a maximum mass of `m_max` with a bottom-heavy Generalized Pareto probability distribution related to the particle mass.
Note that `m_min` and `m_max` must have a dynamic range of less than 15 orders of magnitude to maintain numerical accuracy.

It is recommended that `m_max` be less than or equal to 10^(-10) planetary masses.

# Arguments
- `n`: Number of dust particles (type = `Int`)
- `m_min`: Minimum particle mass in planetary masses.
- `m_max`: Maximum particle mass in planetary masses.
- `ξ`: Shape coefficient of Generalized Pareto probability distribution (the default value is 0.01). The greater this value is, the greater the probability that particles will tend toward `m_min`.


# Returns
- `m`: Array of length `n` of random masses in planetary masses.
"""

function create_masses(
        n::Int,
        m_min::Real,
        m_max::Real,
        seed=nothing,
        ξ::Float64=0.01,
    )
    
	@assert log10(m_max) - log10(m_min) < 15.0 # particle dynamical range must be less than 15 orders of magnitude.
	@assert 0. < ξ <= 1. # ξ must be a value between 0 and 1
	@assert m_max <= 10^(-10)

    if isdefined(seed,:Int)
        Random.seed!(seed) # sets random seed for initial conditions.
    end

	m = zeros(Float64,n) 
	m = rand(GeneralizedPareto(0,1,ξ),n) # probability distribution localized at 0
	m = (m./maximum(m)).* m_max .+ m_min # normalizing distribution to the mass limits we want
	return m
end
export create_masses
