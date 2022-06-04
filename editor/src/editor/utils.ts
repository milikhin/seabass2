import { RawEditorConfig } from '../api/api-interface'

type INDENT_STYLE = 'space'|'tab'
const DEFAULT_INDENT_SIZE = 2
const DEFAULT_INDENT_STYLE = 'space'

export interface SeabassEditorConfig {
  tabWidth: number
  indentSize: number
  indentStyle: INDENT_STYLE
}

export function parseEditorConfig (config?: RawEditorConfig): SeabassEditorConfig {
  return {
    indentSize: config?.indent_size ?? DEFAULT_INDENT_SIZE,
    tabWidth: config?.tab_width ?? config?.indent_size ?? DEFAULT_INDENT_SIZE,
    indentStyle: config?.indent_style ?? DEFAULT_INDENT_STYLE
  }
}
