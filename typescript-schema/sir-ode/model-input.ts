/**
 * A generalized description of the input to an epidemiological model.
 */
export interface SIRInput {
  p: number[]
  u0: number[]
  tspan: number[]
  dt?: number
}

export interface ModelInput {
  input: SIRInput | SIRInput[]
}
