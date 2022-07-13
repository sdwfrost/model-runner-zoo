# Model Runner Zoo

Examples of models plus connectors suitable for use with the Model Runner.

## sir-ode model

This is a simple example of an SIR model that is run to steady state. The final size, the peak infected, and the time of the peak infected is returned, alongside the times and states of the model.

## Schema

### Input schema

The input schema defines a vector of model parameters, `p`, a vector of initial conditions, `u0`, a timespan over which to simulate the model, `tspan`, and an optional time interval, `dt`, at which to compute the states. The input schema allows a single instance of input parameters, or an array to be passed, facilitating batch running of multiple simulations.

```typescript
export interface SIRInput {
  p: number[]
  u0: number[]
  tspan: number[]
  dt?: number
}

export interface ModelInput {
  input: SIRInput | SIRInput[]
}

```

### Output schema

The output schema embeds the model input into `metadata`, and also returns a vector of times at which the model is run, `t`, and a matrix of states, `u`, as well as an optional vector of outputs computed from the model.

```typescript
import { SIRInput } from './model-input'

export interface SIROutput {
  metadata: SIRInput
  t: number[]
  u: number[][]
  outputs?: number[]
}

export interface ModelOutput {
  output: SIROutput | SIROutput[]
}
```
