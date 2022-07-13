# Libraries
using OrdinaryDiffEq
using DiffEqCallbacks
using Optim
using JSON
using JSONSchema

# IO
if length(ARGS)>0
    model_input_fn = ARGS[1]
    model_output_fn = ARGS[2]
    model_input_schema_fn = ARGS[3]
    model_output_schema_fn = ARGS[4]
else
    cd(@__DIR__)
    model_input_fn = "test/input.json"
    model_output_fn = "output/data.json"
    model_input_schema_fn = "schema/input.json"
    model_output_schema_fn = "schema/output.json"
end

# Read schema
model_input_schema = Schema(JSON.parsefile(model_input_schema_fn))
model_output_schema = Schema(JSON.parsefile(model_output_schema_fn))

# Read input and validate
model_input = JSON.parsefile(model_input_fn)
model_input_check = validate(model_input_schema, model_input)

if model_input_check != nothing
    display(model_input_check)
    exit(1)
end

# Model definition
function sir_ode(u,p,t)
    (s,i,r) = u
    (β,γ) = p
    ds = -β*s*i
    di = β*s*i - γ*i
    dr = γ*i
    [ds,di,dr]
end

num_simulations = length(model_input)

model_output = Dict("output" => [])
for i in 1:num_simulations
    input = model_input["input"][i]
    # Convert inputs from JSON
    tlist = input["tspan"]
    tspan = (tlist[1],tlist[2])
    u0 = convert(Array{Float64,1}, input["u0"]); # s,i,r
    p = convert(Array{Float64,1}, input["p"]); # β,γ

    # Run model until steady state
    solver = ROS34PW3()
    prob = ODEProblem(sir_ode,u0,tspan,p)
    sol = solve(prob,solver,callback=TerminateSteadyState());

    # Generate outputs
    ## Final size
    fs = sol[end][3]
    tss = sol.t[end]
    f = (t) -> -sol(t,idxs=2)
    opt = Optim.optimize(f,0.0,tss)
    pk = -opt.minimum
    pkt = opt.minimizer

    # Extract outputs and validate
    output = Dict("metadata" => input, "t" => sol.t, "u" => [vec(sol(sol.t,idxs=i)) for i in 1:3], "outputs" => [fs, pk, pkt])
    push!(model_output["output"],output)
end

model_output_check = validate(model_output_schema, model_output)
if model_output_check != nothing
    display(model_output_check)
    exit(1)
end

# Save outputs
open(model_output_fn,"w") do f
    JSON.print(f,model_output)
end

#display(model_output)

# Exit without errors
exit(0)
