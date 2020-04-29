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

  // #region AP

  _apiOnBeautify () {
    this._editor.beautify()
  }

  _apiOnLoadFile ({ filePath, content = '', readOnly = false }) {
    if (!filePath) {
      throw new InvalidArgError(`${filePath} is required to load file into editor`)
    }

    this._editor.loadFile(filePath, content, readOnly)
  }

  _apiOnRedo () {
    this._editor.redo()
  }

  _apiOnRequestSaveFile ({ filePath }) {
    const value = this._editor.getContent(filePath)
    this._sendApiMessage('saveFile', {
      content: value,
      filePath,
      responseTo: 'requestSaveFile'
    })
  }

  _apiOnUndo () {
    this._editor.undo()
  }

  // #endregion

  _handleStateChanged = ({ hasUndo, hasRedo, filePath }) => {
    this._sendApiMessage('stateChanged', {
      hasUndo,
      hasRedo,
      filePath
    })
  }

  _onMessage = (msg) => {
    const { action, data } = JSON.parse(msg.data)

    try {
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
