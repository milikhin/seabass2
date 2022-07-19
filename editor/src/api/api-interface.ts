import { InputPreferences, SeabassSailfishPreferences, ViewportOptions } from '../app/model'
import { KeyDownOptions } from '../editor/editor'

export interface ApiTransport {
  send: (message: Record<string, unknown>) => void
}

export enum API_TRANSPORT {
  /** SailfishOS-specific API backend */
  SAILFISH_WEBVIEW = 'Sailfish webView',
  /** WebSocket-based API backend */
  WEB_SOCKET = 'WebSocket',
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

/** possible payload of API messages */
export interface IncomingMessagePayload {
  closeFile: FileActionOptions
  fileSaved: undefined
  keyDown: KeyDownOptions
  viewportChange: ViewportOptions
  loadFile: FileLoadOptions
  openFile: FileActionOptions
  oskVisibilityChanged: undefined
  redo: undefined
  requestFileSave: FileActionOptions
  setPreferences: InputPreferences
  setSailfishPreferences: SeabassSailfishPreferences
  undo: undefined
  toggleReadOnly: undefined
}

/** Incoming API message from a platform-specific app */
export interface IncomingApiMessage<T extends keyof IncomingMessagePayload> {
  action: T
  data: IncomingMessagePayload[T]
}
