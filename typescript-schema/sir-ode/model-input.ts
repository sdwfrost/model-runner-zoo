/**
 * A generalized description of the input to an epidemiological model.
 */
export interface ModelInput {
  p: number[]
  u0: number[]
  tspan: number[]
  dt?: number
}
