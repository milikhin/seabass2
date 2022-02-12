import Editor from '../editor/editor'
import { RawEditorConfig } from '../types'

export enum API_BACKEND {
  /** SailfishOS API backend */
  SAILFISH_WEBVIEW = 'Sailfish webView',
  /** Common QT URL-based API backend */
  URL_HANDLER = 'URL handler',
}

export interface ApiOptions {
  /** Welcome notes root elem */
  welcomeElem: HTMLElement
  /** Tabs root elem */
  rootElem: HTMLElement
  /** Platform-specific API backend */
  apiBackend: API_BACKEND
}

export interface IncomingMessage<T> {
  action: keyof Editor
  data: T & {
    filePath?: string
  }
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

export interface OutgoingMessage {
  action: string
  data: Record<string, unknown>
}
