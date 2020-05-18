/* globals localStorage */
import Editor from './editor'
import { InvalidArgError } from './errors'

class Api {
  constructor ({ notifyOnLoaded, apiBackend = 'navigatorQt' } = {}) {
    this._tabs = []
    this._apiBackend = apiBackend
    this._editor = undefined
    this._preferences = {}
    this._rootElem = document.getElementById('root')
    this._welcomeElem = document.getElementById('welcome')

    this._registerApiHandler()
    if (notifyOnLoaded) {
      this._sendApiMessage('appLoaded', this._getSavedPreferences())
    }
  }

  get NON_FILE_ACTIONS () {
    return [
      'closeFile',
      'loadFile',
      'openFile',
      'setPreferences'
    ]
  }

  _createTab (filePath) {
    const editorElem = document.createElement('div')
    this._rootElem.appendChild(editorElem)
    editorElem.classList.add('editor')

    const tab = {
      filePath,
      editor: new Editor({ elem: editorElem }),
      elem: editorElem
    }
    tab.editor.setPreferences(this._preferences)
    this._tabs.push(tab)
    this._registerEditorEventsHandler(tab.editor)

    this._showTab(tab)
    return tab
  }

  _showTab (tab) {
    this._editor = tab.editor
    this._tabs.forEach(({ elem }) => { elem.style.display = 'none' })

    this._welcomeElem.style.display = 'none'
    this._rootElem.style.display = 'block'
    tab.elem.style.display = ''
    this._editor.activate()
  }

  _showWelcomeNote () {
    this._welcomeElem.style.display = 'block'
    this._rootElem.style.display = 'none'
  }

  // #region API

  _apiOnCloseFile ({ filePath }) {
    if (!filePath) {
      throw new InvalidArgError(`${filePath} is required to load file into editor`)
    }

    const tabIndex = this._tabs.findIndex(({ filePath: tabFile }) => tabFile === filePath)
    if (tabIndex === -1) {
      return
    }

    const tab = this._tabs[tabIndex]
    tab.editor.destroy()
    this._tabs.splice(tabIndex, 1)

    if (!this._tabs.length) {
      this._showWelcomeNote()
    }
  }

  /**
   * 'beautify' command handler: intended to auto format file content
   * @returns {undefined}
   */
  _apiOnBeautify () {
    this._editor.beautify()
  }

  /**
   * 'navigateLeft' command handler: intended to move cursor left
   * @returns {undefined}
   */
  _apiOnNavigateLeft () {
    this._editor.navigateLeft()
  }

  /**
   * 'navigateRight' command handler: intended to move cursor right
   * @returns {undefined}
   */
  _apiOnNavigateRight () {
    this._editor.navigateRight()
  }

  /**
   * 'navigateDown' command handler: intended to move cursor down
   * @returns {undefined}
   */
  _apiOnNavigateDown () {
    this._editor.navigateDown()
  }

  /**
   * 'navigateUp' command handler: intended to move cursor up
   * @returns {undefined}
   */
  _apiOnNavigateUp () {
    this._editor.navigateUp()
  }

  /**
   * 'navigateLineStart' command handler: intended to move cursor to the start of the line
   * @returns {undefined}
   */
  _apiOnNavigateLineStart () {
    this._editor.navigateLineStart()
  }

  /**
   * 'navigateLineEnd' command handler: intended to move cursor to the end of the line
   * @returns {undefined}
   */
  _apiOnNavigateLineEnd () {
    this._editor.navigateLineEnd()
  }

  /**
   * 'navigateFileStart' command handler: intended to move cursor to the 1:1
   * @returns {undefined}
   */
  _apiOnNavigateFileStart () {
    this._editor.navigateFileStart()
  }

  /**
   * 'navigateFileEnd' command handler: intended to move cursor to the last symbol of the file
   * @returns {undefined}
   */
  _apiOnNavigateFileEnd () {
    this._editor.navigateFileEnd()
  }

  _apiOnFileSaved ({ filePath, content }) {
    const tab = this._tabs.find(({ filePath: tabFile }) => tabFile === filePath)
    if (tab) {
      tab.editor.setSavedContent(content)
    }
  }

  /**
   * 'loadFile' command handler: intended to load given content to the editor
   * @param {string} filePath - /path/to/file - used as file ID
   * @param {string} content - file content
   * @param {boolean} [readOnly=false] - read only flag
   * @returns {undefined}
   */
  _apiOnLoadFile ({ filePath, content = '', readOnly = false }) {
    if (!filePath) {
      throw new InvalidArgError(`${filePath} is required to load file into editor`)
    }

    const { editor } = this._createTab(filePath)
    editor.loadFile(filePath, content, readOnly)
  }

  _apiOnOpenFile ({ filePath }) {
    if (!filePath) {
      throw new InvalidArgError(`${filePath} is required to load file into editor`)
    }

    const tab = this._tabs.find(({ filePath: tabFile }) => tabFile === filePath)
    if (!tab) {
      return
    }
    this._showTab(tab)
  }

  /**
   * 'redo' command handler: intended to redo latest changes
   * @returns {undefined}
   */
  _apiOnRedo () {
    this._editor.redo()
  }

  /**
   * 'requestFileSave' command handler: intended to request and save file content
   * @param {string} filePath - /path/to/file - used as file ID
   * @returns {undefined}
   */
  _apiOnRequestSaveFile ({ filePath }) {
    const value = this._editor.getContent(filePath)
    this._sendApiMessage('saveFile', {
      content: value,
      filePath,
      responseTo: 'requestSaveFile'
    })
  }

  /**
   * Set editor preferences
   *
   * @param {Object} options - options to set
   * @param {boolean}  [options.isDarkTheme] - `true` to set dark theme, `false` to set light theme
   * @returns {undefined}
   */
  _apiOnSetPreferences (options) {
    if (options.isSailfishToolbarOpened !== undefined) {
      window.localStorage.setItem('sailfish__isToolbarOpened', options.isSailfishToolbarOpened)
    }

    this._preferences = options
    this._tabs.forEach(({ editor }) => {
      editor.setPreferences(options)
    })
  }

  /**
   * 'toggleReadOnly' command handler: intended to toggle readOnly mode
   * @returns {undefined}
   */
  _apiOnToggleReadOnly () {
    this._editor.toggleReadOnly()
  }

  /**
   * 'undo' command handler: intended to undo latest changes
   * @returns {undefined}
   */
  _apiOnUndo () {
    this._editor.undo()
  }

  // #endregion API

  _getSavedPreferences () {
    const isSailfishToolbarOpened = localStorage.getItem('sailfish__isToolbarOpened')
    return {
      isSailfishToolbarOpened: isSailfishToolbarOpened ? JSON.parse(isSailfishToolbarOpened) : undefined
    }
  }

  _handleStateChanged = ({ hasChanges, hasUndo, hasRedo, filePath, isReadOnly }) => {
    this._sendApiMessage('stateChanged', {
      hasChanges,
      hasUndo,
      hasRedo,
      filePath,
      isReadOnly
    })
  }

  _onMessage = ({ action, data }) => {
    try {
      const apiMethod = `_apiOn${action.charAt(0).toUpperCase()}${action.slice(1)}`
      if (!this[apiMethod]) {
        console.warn(`${action} is not implemented`)
        return
      }

      if (this.NON_FILE_ACTIONS.indexOf(action) === -1 && data.filePath !== this._editor.getFilePath()) {
        throw new InvalidArgError(`file ${data.filePath} is not loaded`)
      }
      return this[apiMethod](data)
    } catch (err) {
      this._sendApiError(err.message)
    }
  }

  _registerApiHandler () {
    switch (this._apiBackend) {
      case 'navigatorQt': {
        navigator.qt.onmessage = (msg) => {
          const payload = JSON.parse(msg.data)
          this._onMessage(payload)
        }
        return
      }
      case 'url':
      default: {
        window.postSeabassApiMessage = (payload) => {
          this._onMessage(payload)
        }
      }
    }
  }

  _registerEditorEventsHandler (editor = this._editor) {
    editor.onChange(this._handleStateChanged)
  }

  _sendApiError (message) {
    this._sendApiMessage('error', { message })
  }

  _sendApiMessage (action, data) {
    const payload = JSON.stringify({ action, data })
    switch (this._apiBackend) {
      case 'navigatorQt': {
        return navigator.qt.postMessage(payload)
      }
      case 'url': {
        document.location = `http://seabass/${encodeURIComponent(payload)}`
        return
      }
      default: {
        console.error('No supported API found')
      }
    }
  }
}

export default function registerApi (options) {
  return new Api(options)
}
