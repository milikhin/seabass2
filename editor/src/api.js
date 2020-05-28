/* globals localStorage */
import { InvalidArgError, NotFoundError } from './errors'
import TabsController from './tabs-controller'

class Api {
  constructor ({
    editorFactory,
    notifyOnLoaded,
    apiBackend = 'navigatorQt',

    welcomeElem,
    rootElem
  } = {}) {
    if (!editorFactory) {
      throw new InvalidArgError('editorFactory is required')
    }
    this._tabsController = new TabsController({
      rootElem,
      editorFactory,
      onStateChange: this._handleStateChanged
    })
    this._apiBackend = apiBackend
    this._editor = undefined
    this._tabsRootElem = rootElem
    this._welcomeElem = welcomeElem

    this._registerApiHandler()
    if (notifyOnLoaded) {
      this._sendApiMessage('appLoaded', this._getSavedPreferences())
    }
  }

  // #region API

  _apiOnCloseFile ({ filePath }) {
    if (!filePath) {
      throw new InvalidArgError('filePath is required to close tab')
    }

    this._tabsController.close(filePath)
    if (this._tabsController.list().length === 0) {
      this._showWelcomeNote()
    }
  }

  /**
   * 'beautify' command handler: intended to auto format file content
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  // _apiOnBeautify ({ filePath }) {
  //   this._tabsController.exec(filePath, 'beautify')
  // }

  /**
   * Returns file content.
   *  API backend must support returning results from JS calls to use the method
   * @param {string} filePath - path/to/file
   * @returns {string} - file content
   */
  _apiOnGetFileContent ({ filePath }) {
    return this._tabsController.exec(filePath, 'getContent')
  }

  /**
   * 'navigateLeft' command handler: intended to move cursor left
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  _apiOnNavigateLeft ({ filePath }) {
    this._tabsController.exec(filePath, 'navigateLeft')
  }

  /**
   * 'navigateRight' command handler: intended to move cursor right
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  _apiOnNavigateRight ({ filePath }) {
    this._tabsController.exec(filePath, 'navigateRight')
  }

  /**
   * 'navigateDown' command handler: intended to move cursor down
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  _apiOnNavigateDown ({ filePath }) {
    this._tabsController.exec(filePath, 'navigateDown')
  }

  /**
   * 'navigateUp' command handler: intended to move cursor up
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  _apiOnNavigateUp ({ filePath }) {
    this._tabsController.exec(filePath, 'navigateUp')
  }

  /**
   * 'navigateLineStart' command handler: intended to move cursor to the start of the line
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  _apiOnNavigateLineStart ({ filePath }) {
    this._tabsController.exec(filePath, 'navigateLineStart')
  }

  /**
   * 'navigateLineEnd' command handler: intended to move cursor to the end of the line
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  _apiOnNavigateLineEnd ({ filePath }) {
    this._tabsController.exec(filePath, 'navigateLineEnd')
  }

  /**
   * 'navigateFileStart' command handler: intended to move cursor to the 1:1
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  _apiOnNavigateFileStart ({ filePath }) {
    this._tabsController.exec(filePath, 'navigateFileStart')
  }

  /**
   * 'navigateFileEnd' command handler: intended to move cursor to the last symbol of the file
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  _apiOnNavigateFileEnd ({ filePath }) {
    this._tabsController.exec(filePath, 'navigateFileEnd')
  }

  _apiOnFileSaved ({ filePath, content }) {
    this._tabsController.exec(filePath, 'setSavedContent', content)
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
      throw new InvalidArgError('filePath is required to load file into editor')
    }

    this._showTabs()
    this._tabsController.create(filePath, content, readOnly)
  }

  /**
   * `openFile` command handler: intended to open previously loaded file
   * @param {string} filePath - /path/to/file
   */
  _apiOnOpenFile ({ filePath }) {
    if (!filePath) {
      throw new InvalidArgError('filePath is required to load file into editor')
    }

    this._tabsController.show(filePath)
  }

  /**
   * 'redo' command handler: intended to redo latest changes
   * @returns {undefined}
   */
  _apiOnRedo ({ filePath }) {
    this._tabsController.exec(filePath, 'redo')
  }

  /**
   * 'requestFileSave' command handler: intended to request and save file content
   * @param {string} filePath - /path/to/file - used as file ID
   * @returns {undefined}
   */
  _apiOnRequestSaveFile ({ filePath }) {
    try {
      const value = this._tabsController.exec(filePath, 'getContent')
      this._sendApiMessage('saveFile', {
        content: value,
        filePath,
        responseTo: 'requestSaveFile'
      })
    } catch (err) {
      if (err instanceof NotFoundError) {
        // requestSaveFile operation must throw error to the platform application if required file is not loaded
        throw new InvalidArgError(`File ${filePath} is not opened`)
      }

      throw err
    }
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

    if (options.textColor && options.linkColor && options.backgroundColor) {
      const styleElem = document.getElementById('theme-css')
      styleElem.sheet.cssRules[0].style.backgroundColor = options.backgroundColor
      styleElem.sheet.cssRules[1].style.color = options.textColor
      styleElem.sheet.cssRules[2].style.color = options.linkColor
    }
    this._tabsController.setPreferences(options)
  }

  /**
   * 'toggleReadOnly' command handler: intended to toggle readOnly mode
   * @returns {undefined}
   */
  _apiOnToggleReadOnly ({ filePath }) {
    this._tabsController.exec(filePath, 'toggleReadOnly')
  }

  /**
   * 'undo' command handler: intended to undo latest changes
   * @returns {undefined}
   */
  _apiOnUndo ({ filePath }) {
    this._tabsController.exec(filePath, 'undo')
  }

  // #endregion API
  // #region PRIVATE

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
      return this[apiMethod](data)
    } catch (err) {
      if (err instanceof NotFoundError) {
        return console.warn(err)
      }
      this._sendApiError(err.message)
    }
  }

  _registerApiHandler () {
    switch (this._apiBackend) {
      case 'navigatorQt': {
        navigator.qt.onmessage = this._handleQtMessage
        return
      }
      case 'url': {
        window.postSeabassApiMessage = this._onMessage
        return
      }
      default: {
        throw new InvalidArgError(`${this._apiBackend} is incorrect API backend. Must be one of (navigatorQt, url)`)
      }
    }
  }

  _handleQtMessage = (msg) => {
    const payload = JSON.parse(msg.data)
    this._onMessage(payload)
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

  _showWelcomeNote () {
    this._welcomeElem.style.display = 'block'
    this._tabsRootElem.style.display = 'none'
  }

  _showTabs () {
    this._welcomeElem.style.display = 'none'
    this._tabsRootElem.style.display = 'block'
  }
  // #endregion PRIVATE
}

export default function registerApi (options = {}) {
  return new Api(options)
}
