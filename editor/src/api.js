import { InvalidArgError } from './errors'

class Api {
  constructor ({ editor, notifyOnLoaded } = {}) {
    this._editor = editor

    this._registerEditorEventsHandler()
    this._registerApiHandler()

    if (notifyOnLoaded) {
      this._sendApiMessage('appLoaded')
    }
  }

  // #region API

  /**
   * 'beautify' command handler: intended to auto format file content
   * @returns undefined
   */
  _apiOnBeautify () {
    this._editor.beautify()
  }

  /**
   * 'navigateLeft' command handler: intended to move cursor left
   * @returns undefined
   */
  _apiOnNavigateLeft () {
    this._editor.navigateLeft()
  }

  /**
   * 'navigateRight' command handler: intended to move cursor right
   * @returns undefined
   */
  _apiOnNavigateRight () {
    this._editor.navigateRight()
  }

  /**
   * 'navigateDown' command handler: intended to move cursor down
   * @returns undefined
   */
  _apiOnNavigateDown () {
    this._editor.navigateDown()
  }

  /**
   * 'navigateUp' command handler: intended to move cursor up
   * @returns undefined
   */
  _apiOnNavigateUp () {
    this._editor.navigateUp()
  }

  /**
   * 'loadFile' command handler: intended to load given content to the editor
   * @param {string} filePath - /path/to/file - used as file ID
   * @param {string} content - file content
   * @param {boolean} [readOnly=false] - read only flag
   * @returns undefined
   */
  _apiOnLoadFile ({ filePath, content = '', readOnly = false }) {
    if (!filePath) {
      throw new InvalidArgError(`${filePath} is required to load file into editor`)
    }

    this._editor.loadFile(filePath, content, readOnly)
  }

  /**
   * 'redo' command handler: intended to redo latest changes
   * @returns undefined
   */
  _apiOnRedo () {
    this._editor.redo()
  }

  /**
   * 'requestFileSave' command handler: intended to request and save file content
   * @param {string} filePath - /path/to/file - used as file ID
   * @returns undefined
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
   * 'toggleReadOnly' command handler: intended to toggle readOnly mode
   * @returns undefined
   */
  _apiOnToggleReadOnly () {
    this._editor.toggleReadOnly()
  }

  /**
   * 'undo' command handler: intended to undo latest changes
   * @returns undefined
   */
  _apiOnUndo () {
    this._editor.undo()
  }

  // #endregion API

  _handleStateChanged = ({ hasUndo, hasRedo, filePath, isReadOnly }) => {
    this._sendApiMessage('stateChanged', {
      hasUndo,
      hasRedo,
      filePath,
      isReadOnly
    })
  }

  _onMessage = (msg) => {
    try {
      const { action, data } = JSON.parse(msg.data)
      const apiMethod = `_apiOn${action.charAt(0).toUpperCase()}${action.slice(1)}`
      if (!this[apiMethod]) {
        console.warn(`${action} is not implemented`)
        return
      }

      if (action !== 'loadFile' && data.filePath !== this._editor.getFilePath()) {
        throw new InvalidArgError(`file ${data.filePath} is not loaded`)
      }
      return this[apiMethod](data)
    } catch (err) {
      this._sendApiError(err.message)
    }
  }

  _registerApiHandler () {
    if (navigator && navigator.qt) {
      navigator.qt.onmessage = this._onMessage
      return
    }

    throw new Error('No supported API found')
  }

  _registerEditorEventsHandler () {
    if (!this._editor) {
      return
    }

    this._editor.onChange(this._handleStateChanged)
  }

  _sendApiError (message) {
    this._sendApiMessage('error', { message })
  }

  _sendApiMessage (action, data) {
    if (navigator && navigator.qt) {
      return navigator.qt.postMessage(JSON.stringify({ action, data }))
    }

    console.error('No supported API found')
  }
}

export default function registerApi (options) {
  return new Api(options)
}
