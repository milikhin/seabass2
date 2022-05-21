/** EditorConfig options (parsed by python lib) */
export interface RawEditorConfig {
  indent_size?: number
  tab_width?: number
}

export interface TabActionPayload {
  filePath: string
}

export interface SeabassEditorPreferences {
  // fontSize: number
  isDarkTheme: boolean
  // useWrapMode: boolean
}

export interface SeabassPreferenes extends SeabassEditorPreferences {
  backgroundColor: string
  highlightColor: string
  textColor: string
  isSailfishToolbarOpened?: boolean
}

export interface SavedSeabassPreferences extends Record<string, unknown> {
  isSailfishToolbarOpened: boolean
}
