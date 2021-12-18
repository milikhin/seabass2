/* globals localStorage */
import Editor from './editor/editor'
import { InvalidArgError, NotFoundError } from './errors'
import TabsController from './tabs'
import {
  getThemeStyleElem,
  setMainWindowColors
} from './theme'
import {
  IncomingMessage,
  OutgoingMessage,
  RawEditorConfig,
  SavedSeabassPreferences,
  SeabassEditorState,
  SeabassPreferenes,
  TabActionPayload
} from './types'
import { parseEditorConfig } from './utils'

enum API_BACKEND {
  /** SailfishOS-specific API backend */
  SAILFISH_WEBVIEW = 'Sailfish webView',
  /** Common URL-based API backend, used in Ubuntu Touch */
  URL_HANDLER = 'URL handler',
}

declare global {
  interface Window {
    postSeabassApiMessage: <T>(msg: IncomingMessage<T>) => void
  }
}

interface ApiOptions {
  welcomeElem: HTMLElement
  rootElem: HTMLElement
  apiBackend: API_BACKEND
}

interface LoadFileOptions {
  filePath: string
  content: string
  isTerminal: boolean
  isReadOnly: boolean
  editorConfig: RawEditorConfig
}

class SeabassApi {
  _welcomeElem: HTMLElement
  _tabsRootElem: HTMLElement
  _apiBackend: API_BACKEND
  _tabsController: TabsController
  _editors: Map<string, Editor>

  constructor ({ apiBackend, rootElem, welcomeElem }: ApiOptions) {
    this._tabsController = new TabsController({ rootElem })
    this._apiBackend = apiBackend
    this._tabsRootElem = rootElem
    this._welcomeElem = welcomeElem
    this._editors = new Map()

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
      editorConfig: parseEditorConfig(data.editorConfig),
      elem: tab.elem,
      filePath: data.filePath,
      isReadOnly: data.isReadOnly,
      isTerminal: data.isTerminal,
      onChange: this._handleStateChanged
    })
    this._editors.set(data.filePath, editor)
    tab.onClose = () => {
      this._editors.delete(data.filePath)
      editor.destroy()
    }
  }

  /**
   * 'requestFileSave' command handler: intended to request and save file content
   * @param {string} filePath - /path/to/file - used as file ID
   * @returns {undefined}
   */
  _apiOnRequestSaveFile ({ filePath }: TabActionPayload): void {
    const editor = this._editors.get(filePath)
    if (editor === undefined) {
      throw new InvalidArgError(`File ${filePath} is not opened`)
    }

    const value = editor.getContent()
    this._sendApiMessage({
      action: 'saveFile',
      data: {
        content: value,
        filePath,
        responseTo: 'requestSaveFile'
      }
    })
  }

  /**
   * 'requestFileSave' command handler: intended to request and save file content
   * @param {string} filePath - /path/to/file - used as file ID
   * @returns {undefined}
   */
  _apiOnCloseFile ({ filePath }: TabActionPayload): void {
    const editor = this._editors.get(filePath)
    if (editor === undefined) {
      throw new InvalidArgError(`File ${filePath} is not opened`)
    }

    this._editors.delete(filePath)
    editor.destroy()
  }

  /**
   * Set editor preferences
   *
   * @param {Object} options - options to set
   * @param {boolean}  [options.isDarkTheme] - `true` to set dark theme, `false` to set light theme
   * @returns {undefined}
   */
  _apiOnSetPreferences (options: SeabassPreferenes): void {
    if (options.isSailfishToolbarOpened !== undefined) {
      window.localStorage.setItem('sailfish__isToolbarOpened', options.isSailfishToolbarOpened.toString())
    }

    const styleElem = getThemeStyleElem()
    if (styleElem == null) {
      return console.warn('Theme colors are ignored as corresponding <style> tag is not found')
    }

    const colors = {
      backgroundColor: options.backgroundColor,
      textColor: options.textColor,
      highlightColor: options.highlightColor
    }

    setMainWindowColors(colors)
    // this._tabsController.setPreferences(options)
  }

  _getSavedPreferences (): SavedSeabassPreferences {
    const isSailfishToolbarOpened = localStorage.getItem('sailfish__isToolbarOpened') === 'true'
    return { isSailfishToolbarOpened }
  }

  _handleStateChanged = (state: SeabassEditorState): void => {
    console.log(state)
    this._sendApiMessage({
      action: 'stateChanged',
      data: state
    })
  }

  _onMessage = <T>({ action, data }: IncomingMessage<T>): unknown => {
    try {
      const apiMethod = `_apiOn${action.charAt(0).toUpperCase()}${action.slice(1)}`
      const methodName = apiMethod as keyof SeabassApi
      if (this[methodName] !== undefined) {
        const handler = this[methodName] as (options: T) => void
        return handler.call(this, data)
      }

      if (data.filePath === undefined) {
        throw new Error(`'${action}' action is not supported`)
      }

      const editor = this._editors.get(data.filePath)
      if (editor === undefined || typeof editor[action] !== 'function') {
        throw new NotFoundError(`${data.filePath} is not opened`)
      }

      type ActionHandler = (data: T) => void
      return (editor[action] as ActionHandler)(data)
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
