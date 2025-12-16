module PlotRound

export PlotMarketOutcome

import Plots

Plots.gr()

function PlotMarketOutcome(n_round, generators, demands, marketOutcome)

	marketPlot = Plots.plot(title="Market Cleared: Round $n_round", size=(800,400), legend=:outerbottom, legendcolumns=3)
    Plots.scatter!(marketPlot, [sum(marketOutcome.generator_dispatch)],[marketOutcome.shadow_price],label="Market clears at: €$(marketOutcome.shadow_price).\n$(sum(marketOutcome.generator_dispatch))MWh dispatched.")

    # note: this sorting will break down when we really get into dynamic stuff (like even a bid price changing over time), so revisit this soon (really the whole thing needs to be rethought

    sorted_demands = sort(demands, rev=true)
    
    start_bid = 0
    for demandBid in sorted_demands
        Plots.plot!(marketPlot, [start_bid,start_bid + demandBid.demand_quantity],[demandBid.offer_price,demandBid.offer_price],fillrange = zero([start_bid,start_bid + demandBid.demand_quantity]), fc=:blues, fa=.3, label=demandBid.name)
        start_bid += demandBid.demand_quantity
        # println("start_bid", start_bid)
    end
    
    sorted_generators = sort(generators)
    
    start_gens = 0
    for generator in sorted_generators
        actual_capacity = isdefined(generator, :capacity_forecast) ? generator.total_capacity * generator.capacity_forecast[n_round] : generator.total_capacity

        Plots.plot!(marketPlot, [start_gens,start_gens + actual_capacity],[generator.marginal_cost,generator.marginal_cost],fillrange = zero([start_gens,start_gens + actual_capacity]), fc=:reds, fa=.3, label=generator.name)
        start_gens += actual_capacity
        # println("start_bid", start_bid)
    end
    return marketPlot

end

end;