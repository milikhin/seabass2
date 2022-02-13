/* globals localStorage */

import Editor from '../editor/editor'
import { SeabassEditorState } from '../editor/types'
import { InvalidArgError, NotFoundError } from '../errors'
import TabsController from '../tabs'
import {
  SavedSeabassPreferences,
  SeabassPreferenes,
  TabActionPayload
} from '../types'
import { setWelcomeScreenColors } from './theme'
import {
  API_BACKEND,
  ApiOptions,
  LoadFileOptions,
  IncomingMessage,
  OutgoingMessage
} from './types'

/** `postSeabassApiMessage` global function is used to communicate with UI */
declare global {
  interface Window {
    postSeabassApiMessage: <T>(msg: IncomingMessage<T>) => void
  }
}

class SeabassApi {
  /** Wecome notes root elem */
  _welcomeElem: HTMLElement
  /** Tabs container elem */
  _tabsRootElem: HTMLElement
  /** Platform-specific API backend name */
  _apiBackend: API_BACKEND
  /** Tabs controller instance */
  _tabsController: TabsController
  /** Opened editors */
  _editors: Map<string, Editor>
  _editorPreferences: {
    isDarkTheme: boolean
  }

  constructor ({ apiBackend, rootElem, welcomeElem }: ApiOptions) {
    this._apiBackend = apiBackend
    this._editors = new Map()
    this._tabsController = new TabsController({ rootElem })
    this._tabsRootElem = rootElem
    this._welcomeElem = welcomeElem
    this._editorPreferences = { isDarkTheme: false }

    this._registerApiHandler()
    this._sendApiMessage({ action: 'appLoaded', data: this._getSavedPreferences() })
  }

  /**
   * 'loadFile' command handler: intended to load given content to the editor
   * @param {string} data.filePath - /path/to/file - used as file ID
   * @param {string} data.content - editor content
   * @param {boolean} [data.readOnly=false] - read only flag
   * @param {boolean} [data.isTerminal=false] - terminal mode flag
   * @param {Object} [data.editorConfig={}] - .editorConfig values
   * @returns {undefined}
   */
  _apiOnLoadFile (data: LoadFileOptions): void {
    this._showTabs()

    const tab = this._tabsController.create({ id: data.filePath })
    const editor = new Editor({
      content: data.content,
      editorConfig: data.editorConfig,
      elem: tab.elem,
      filePath: data.filePath,
      isReadOnly: data.isReadOnly,
      isTerminal: data.isTerminal,
      isDarkTheme: this._editorPreferences.isDarkTheme,
      onChange: this._handleStateChanged
    })
    this._editors.set(data.filePath, editor)
    tab.onClose = () => {
      this._editors.delete(data.filePath)
      editor.destroy()
    }
  }

  /**
   * 'requestFileSave' command handler: request file saving operation
   * @param {string} filePath - /path/to/file - full path, used as file ID
   * @returns {undefined}
   */
  _apiOnRequestSaveFile ({ filePath }: TabActionPayload): void {
    const editor = this._editors.get(filePath)
    if (editor === undefined) {
      throw new InvalidArgError(`File ${filePath} is not opened`)
    }

    this._sendApiMessage({
      action: 'saveFile',
      data: {
        content: editor.getContent(),
        filePath
      }
    })
  }

  /**
   * 'requestFileSave' command handler: intended to request and save file content
   * @param {string} filePath - /path/to/file - used as file ID
   * @returns {undefined}
   */
  _apiOnCloseFile ({ filePath }: TabActionPayload): void {
    this._tabsController.close(filePath)
  }

  /**
   * Set editor preferences
   *
   * @param {Object} options - options to set
   * @param {string} options.backgroundColor - theme color (background)
   * @param {string} options.highlightColor - theme color (text highlight)
   * @param {string} options.textColor - theme color (text)
   * @param {boolean} [options.isDarkTheme] - `true` to set dark theme, `false` to set light theme
   * @param {boolean} [options.isSailfishToolbarOpened]
   * @returns {undefined}
   */
  _apiOnSetPreferences (options: SeabassPreferenes): void {
    if (options.isSailfishToolbarOpened !== undefined) {
      window.localStorage.setItem('sailfish__isToolbarOpened',
        options.isSailfishToolbarOpened.toString())
    }

    setWelcomeScreenColors({
      backgroundColor: options.backgroundColor,
      textColor: options.textColor,
      highlightColor: options.highlightColor
    })
    this._editorPreferences = {
      isDarkTheme: options.isDarkTheme
    }
    for (const editor of this._editors.values()) {
      editor.setPreferences(this._editorPreferences)
    }
  }

  _getSavedPreferences (): SavedSeabassPreferences {
    const isSailfishToolbarOpened = localStorage.getItem('sailfish__isToolbarOpened') === 'true'
    return { isSailfishToolbarOpened }
  }

  _handleStateChanged = (state: SeabassEditorState): void => {
    this._sendApiMessage({
      action: 'stateChanged',
      data: state
    })
  }

  _onMessage = <T>({ action, data }: IncomingMessage<T>): unknown => {
    type ApiActionHandler = (options: T) => void

    try {
      const apiMethod = `_apiOn${action.charAt(0).toUpperCase()}${action.slice(1)}`
      const methodName = apiMethod as keyof SeabassApi
      if (this[methodName] !== undefined) {
        return (this[methodName] as ApiActionHandler)(data)
      }

      if (data.filePath === undefined) {
        throw new Error(`'${action}' action is not supported`)
      }

      const editor = this._editors.get(data.filePath)
      if (editor === undefined || typeof editor[action] !== 'function') {
        throw new NotFoundError(`${data.filePath} is not opened`)
      }

      return (editor[action] as ApiActionHandler)(data)
    } catch (err) {
      if (err instanceof NotFoundError) {
        return console.warn(err)
      }
      this._sendApiError((err as Error).message)
    }
  }

  _registerApiHandler (): void {
    window.postSeabassApiMessage = this._onMessage
  }

  _sendApiError (message: string): void {
    this._sendApiMessage({ action: 'error', data: { message } })
  }

  _sendApiMessage ({ action, data }: OutgoingMessage): void {
    const payload = JSON.stringify({ action, data })
    switch (this._apiBackend) {
      case API_BACKEND.SAILFISH_WEBVIEW: {
        const evt = new CustomEvent('framescript:action', {
          detail: { action, data }
        })
        document.dispatchEvent(evt)
        return
      }
      case API_BACKEND.URL_HANDLER: {
        return window.location.assign(`http://seabass/${encodeURIComponent(payload)}`)
      }
    }
  }

  _showWelcomeNote (): void {
    this._welcomeElem.style.display = 'block'
    this._tabsRootElem.style.display = 'none'
  }

  _showTabs (): void {
    this._welcomeElem.style.display = 'none'
    this._tabsRootElem.style.display = 'block'
  }
}

export default function registerApi (options: ApiOptions): SeabassApi {
  return new SeabassApi(options)
}
