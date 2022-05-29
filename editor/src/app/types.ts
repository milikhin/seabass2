import { API_TRANSPORT, RawEditorConfig } from '../api/api-interface'

export interface SeabassOptions {
  /** Welcome notes elem */
  welcomeElem: HTMLElement
  /** App root elem */
  rootElem: HTMLElement
  /** Platform-specific API backend */
  apiBackend: API_TRANSPORT
}

export interface LoadFileOptions {
  /** Full file path */
  filePath: string
  /** File content */
  content: string
  /** Terminal tab flag */
  isTerminal: boolean
  /** Readonly tab flag */
  isReadOnly: boolean
  /** .editorconfig options */
  editorConfig: RawEditorConfig
}
