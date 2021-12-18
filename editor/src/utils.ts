import { RawEditorConfig, SeabassEditorConfig } from './types'

const DEFAULT_INDENT_SIZE = 2

export function parseEditorConfig (config?: RawEditorConfig): SeabassEditorConfig {
  return {
    indentSize: config?.indent_size ?? DEFAULT_INDENT_SIZE,
    tabWidth: config?.tab_width ?? DEFAULT_INDENT_SIZE
  }
}
