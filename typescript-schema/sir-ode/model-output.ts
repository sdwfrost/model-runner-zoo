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
