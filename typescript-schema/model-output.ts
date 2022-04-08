import { ModelInput } from './model-input'

export interface ModelOutput {
  metadata: ModelInput
  t: number[]
  u: number[][]
  outputs?: number[]
}
