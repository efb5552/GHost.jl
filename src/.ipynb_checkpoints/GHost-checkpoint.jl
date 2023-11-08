module GHost

mods = [ # list of all custom packages
    "pythagoras",
    "create_masses",
    "initial_conditions",
    "acceleration",
    "position_change",
    "velocity_change",
    "move_particle",
    "orbit_matrix",
    "animate_movements",
    "energy_arrays",
    "plot_movements",
    "system_energy",
    "grav_const",
    "create_animation",
    "tag",
]

for file in mods
    include("$file.jl")
end

end # module GHost
