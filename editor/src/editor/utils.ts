import { RawEditorConfig } from '../api/api-interface'

const DEFAULT_INDENT_SIZE = 2

export interface SeabassEditorConfig {
  tabWidth: number
  indentSize: number
}

export function parseEditorConfig (config?: RawEditorConfig): SeabassEditorConfig {
  return {
    indentSize: config?.indent_size ?? DEFAULT_INDENT_SIZE,
    tabWidth: config?.tab_width ?? DEFAULT_INDENT_SIZE
  }
}
