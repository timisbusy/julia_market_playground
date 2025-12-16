module Demand

export Demand, importFromFile, isless

import YAML, StructTypes
import Base: isless

# a test struct for a demand asset

mutable struct Demand
    demand_quantity::Int64
    offer_price::Int64
    name::String
    Demand() = new() # note that this line is important so we can use an ampty constructor
end

# to short by offer price
isless(a::Demand, b::Demand) = isless(a.offer_price, b.offer_price)

function importFromFile(filepath)



    imported_demands = Demand[]

    # the data comes in with a dictionary that is open to any type of symbol

    data = YAML.load_file(filepath; dicttype=Dict{Symbol,Any})

    for (iter, dict) in enumerate(data[:demands])
        demand = Demand() # create the empty generator
        for (key, val) in dict
            setproperty!(demand, key, val) # set each property using the symbol type
        end
        setproperty!(demand,:name,"d$iter")
        push!(imported_demands, demand)
    end
    return imported_demands

end

end;