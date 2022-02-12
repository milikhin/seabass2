export interface SeabassEditorConfig {
  tabWidth: number
  indentSize: number
}

export interface SeabassEditorState extends Record<string, unknown>{
  filePath: string
  hasChanges: boolean
  hasRedo: boolean
  hasUndo: boolean
  isReadOnly: boolean
  selectedText: string
}
