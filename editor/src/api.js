import { InvalidArgError } from './errors'

class Api {
  constructor ({ editor } = {}) {
    this._editor = editor
    this._registerApiHandler()
  }

  // #region API

  _apiOnBeautify () {
    this._editor.beautify()
  }

  _apiOnLoadFile ({ filePath, content = '' }) {
    if (!filePath) {
      throw new InvalidArgError(`${filePath} is required to load file into editor`)
    }
    this._editor.loadFile(filePath, content)
  }

  _apiOnRequestSaveFile ({ filePath }) {
    const value = this._editor.getContent(filePath)
    this._sendApiMessage('saveFile', {
      content: value,
      filePath,
      responseTo: 'requestSaveFile'
    })
  }

  // #endregion

  _onMessage = (msg) => {
    const { action, data } = JSON.parse(msg.data)

    const apiMethod = `_apiOn${action.charAt(0).toUpperCase()}${action.slice(1)}`
    if (!this[apiMethod]) {
      return console.warn(`${action} is not implemented`)
    }

    try {
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
