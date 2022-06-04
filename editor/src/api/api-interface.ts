export enum API_TRANSPORT {
  /** SailfishOS API backend */
  SAILFISH_WEBVIEW = 'Sailfish webView',
  /** Common QT URL-based API backend */
  URL_HANDLER = 'URL handler',
}

/** EditorConfig options (parsed by python lib) */
export interface RawEditorConfig {
  indent_size?: number
  tab_width?: number
  indent_style?: 'space'|'tab'
}

export interface FileActionOptions {
  /** Full file path */
  filePath: string
}

export interface FileLoadOptions extends FileActionOptions {
  /** File content */
  content: string
  /** Terminal tab flag */
  isTerminal: boolean
  /** Readonly tab flag */
  isReadOnly: boolean
  /** .editorconfig options */
  editorConfig: RawEditorConfig
}
