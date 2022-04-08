# Libraries
import sys
import os
import numpy as np
from scipy.integrate import solve_ivp
from scipy.interpolate import InterpolatedUnivariateSpline
import json
from jsonschema import validate

ARGS = sys.argv
if len(ARGS)>1:
    model_input_fn = ARGS[1]
    model_output_fn = ARGS[2]
    model_input_schema_fn = ARGS[3]
    model_output_schema_fn = ARGS[4]
else:
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)
    model_input_fn = "test/input.json"
    model_output_fn = "output/data.json"
    model_input_schema_fn = "schema/input.json"
    model_output_schema_fn = "schema/output.json"

# Read schema
model_input_schema = json.load(open(model_input_schema_fn, 'r'))
model_output_schema = json.load(open(model_output_schema_fn, 'r'))

# Read input and validate
model_input = json.load(open(model_input_fn, 'r'))
model_input_check = validate(model_input, model_input_schema)

if model_input_check != None:
    sys.exit(1)

# Model definition 
def model(t, u, p):
    b,g = p
    S,I,R = u
    dS = -b*S*I
    dI = b*S*I-g*I
    dR = g*I 
    return [dS,dI,dR]

# Stop integration at steady state
# See https://scicomp.stackexchange.com/questions/16325/dynamically-ending-ode-integration-in-scipy
def steady_state(t,u,p,f,tol):
    global flag
    du = f(t,u,p)
    condition = np.max(np.abs(du))<tol
    if flag == 1:
        if condition:
            test = [0]
        else:
            test = [1]
        flag = 0
    else:
        if condition:
            test = np.array([0])
        else:
            test = np.array([1])
    return test

# Define terminal condition and type-change flag
tol = 1e-6
limit = lambda t, u: steady_state(t,u,p,model,tol)
limit.terminal = True                                                                                                                                                                                   
global flag
flag = 1

# Extract inputs from JSON
tspan = model_input['tspan']
u0 = model_input['u0']
p = model_input['p']

# Run model
sol = solve_ivp(lambda t, u: model(t, u, p),
                tspan,
                u0,
                events = limit)

# Generate outputs
## Final size
fs = sol.y[2,-1]
## Peak infected and peak time
f = InterpolatedUnivariateSpline(sol.t, sol.y[1,:], k=4)
cr_pts = f.derivative().roots()
cr_pts = np.append(cr_pts, (sol.t[0], sol.t[-1]))  # also check the endpoints of the interval
cr_vals = f(cr_pts)
max_index = np.argmax(cr_vals)
pk = cr_vals[max_index]
pkt = cr_pts[max_index]

# Extract outputs and validate
model_output = {"metadata": model_input, "t": sol.t.tolist(), "u": sol.y.tolist(), "outputs":[fs, pk, pkt]}
model_output_check = validate(model_output, model_output_schema)

if model_output_check != None:
    sys.exit(1)

# Save outputs
with open(model_output_fn,"w") as f:
    json.dump(model_output, f, indent="  ")

print(model_output)

# Exit without errors
sys.exit(0)
