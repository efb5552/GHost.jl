"""
`pythagoras(x,y)`

Pythagorean theorem to determine the radial component of a set of numbers or index of two arrays (`x`,`y`) for either a single number or an Array.

# Arguments
- `x`: Some number or array of type equivalent to that of `y`.
- `y`: Some number or array of type equivalent to that of `x`.

# Returns
- Radial component between `x` and `y`. 

"""

function pythagoras(x,y)

	@assert typeof(x) == typeof(y) ! String
    @assert length(x) == length(y)
    
	if x isa Matrix || x isa Array || x isa Vector # if multiple numbers have the matrix arithmetic
		return  sqrt.(x.^2 + y.^2)
	elseif typeof(x) <: Number # normal math arithmetic
		return  sqrt(x^2 + y^2)
	end
end
export pythagoras 