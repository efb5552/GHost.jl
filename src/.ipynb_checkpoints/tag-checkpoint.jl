"""
`tag(number)`

Converts a number into a simplified string in scientific notation.

# Arguments
- `number` (Real): Some number that is to be converted into a scientific notation string.

# Returns
- `number_name` (String): String version of inputted number in simple scientific notation.
"""

function tag(number::Real)

    number_name = string(number)
    number_name = split(number_name,".")[1] * "e" * split(number_name,"e")[2]
    return number_name
end
export tag