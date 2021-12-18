import Editor from './editor/editor'

export interface IncomingMessage<T> {
  action: keyof Editor
  data: T & {
    filePath?: string
  }
}

export interface OutgoingMessage {
  action: string
  data: Record<string, unknown>
}

export interface SeabassEditorState extends Record<string, unknown>{
  filePath: string
  hasChanges: boolean
  hasRedo: boolean
  hasUndo: boolean
  isReadOnly: boolean
  selectedText: string
}

export interface RawEditorConfig {
  indent_size?: number
  tab_width?: number
}

export interface SeabassEditorConfig {
  tabWidth: number
  indentSize: number
}

export interface TabActionPayload {
  filePath: string
}

export interface SeabassPreferenes {
  backgroundColor: string
  highlightColor: string
  textColor: string
  isSailfishToolbarOpened?: boolean
}

export interface SavedSeabassPreferences extends Record<string, unknown> {
  isSailfishToolbarOpened: boolean
}

export interface SeabassEditorPreferences {
  fontSize: number
  isDarkTheme: boolean
  useWrapMode: boolean
}
