module Generator

export importFromFile, Generator, isless

import YAML, StructTypes
import Base: isless



# a test struct for a generator asset

mutable struct Generator
    total_capacity::Int64
    marginal_cost::Int64
    ramp_up::Int64
    ramp_down::Int64
    min_up::Int64
    min_down::Int64
    capacity_forecast::Vector{Float64}
    name::String
    Generator() = new() # note that this line is important so we can use an ampty constructor
end

# to short by marginal cost
isless(a::Generator, b::Generator) = isless(a.marginal_cost, b.marginal_cost)



function importFromFile(filepath)


    imported_generators = Generator[]

    # the data comes in with a dictionary that is open to any type of symbol

    data = YAML.load_file(filepath; dicttype=Dict{Symbol,Any})

    for (iter, dict) in enumerate(data[:generators])
        gen = Generator() # create the empty generator
        for (key, val) in dict
            setproperty!(gen, key, val) # set each property using the symbol type
        end
        setproperty!(gen,:name,"g$iter")
        push!(imported_generators, gen)
    end
    return imported_generators
end

end;