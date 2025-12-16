module Market

export MarketOutcome, Clear

import JuMP, GLPK, MathOptInterface

mutable struct MarketOutcome
	termination_status::MathOptInterface.TerminationStatusCode
    objective_value::Number
    shadow_price::Number
    demand_dispatch::Vector{Number}
    generator_dispatch::Vector{Number}
    MarketOutcome() = new()
end

function Clear(n_market_periods, generators, demands)
	marketOutcomes = Vector{}()

	for mcp in 1:n_market_periods

	    model = JuMP.Model(GLPK.Optimizer)
	    
	    # add my variables for Quantities supplied and demanded
	    ds = JuMP.@variable(model, Qd[1:length(demands)] >=0)
	    
	    gs = JuMP.@variable(model, Qg[1:length(generators)] >=0)
	    
	    # add upper bounds
	    for (iter, demand) in enumerate(ds)
	        JuMP.set_upper_bound(demand,demands[iter].demand_quantity)
	    end
	    
	    for (iter, gen) in enumerate(gs)
	        if isdefined(generators[iter],:capacity_forecast)
	            actual_capacity = generators[iter].total_capacity*generators[iter].capacity_forecast[mcp]
	            JuMP.set_upper_bound(gen,actual_capacity)
	        else  
	            JuMP.set_upper_bound(gen,generators[iter].total_capacity)
	        end
	    end
	    
	    # add objective
	    JuMP.@objective(model, Max, sum(Qd[iter_d]*demands[iter_d].offer_price for iter_d in 1:length(demands))- sum(Qg[iter_g]*generators[iter_g].marginal_cost for iter_g in 1:length(generators)))
	    
	    
	    # add constraints
	    
	    # constraint 1: system balance
	    
	    JuMP.@constraint(model, system_balance, sum(Qd[iter_d] for iter_d in 1:length(demands)) - sum(Qg[iter_g] for iter_g in 1:length(generators)) == 0)
	    
	    
	    # JuMP.print(model)
	    
	    JuMP.optimize!(model)

	    marketOutcome = MarketOutcome()
	    marketOutcome.termination_status = JuMP.termination_status(model)
	    marketOutcome.objective_value =  JuMP.objective_value(model)
	    
	    marketOutcome.shadow_price = JuMP.shadow_price(system_balance)
	    
	    marketOutcome.demand_dispatch = JuMP.value(Qd)
	    marketOutcome.generator_dispatch = JuMP.value(Qg)

	    push!(marketOutcomes, marketOutcome)
	end


	return marketOutcomes 
end
	

end;