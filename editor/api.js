class Api {
  constructor () {
    this._editor = undefined
    this._registerApiHandler()
  }

  setEditor (editor) {
    this._editor = editor

    this._editor.onChange(this._onContentChanged)
  }

  // #region API

  _apiOnBeautify () {
    this._editor.beautify()
  }

  _apiOnLoadFile ({ filePath, content }) {
    this._editor.loadFile(filePath, content)
  }

  // #endregion

  _onContentChanged = ({ value, filePath }) => {
    this._sendApiMessage('saveFile', {
      content: value,
      filePath
    })
  }

  _onMessage = (msg) => {
    const { action, data } = JSON.parse(msg.data)

    const apiMethod = `_apiOn${action.charAt(0).toUpperCase()}${action.slice(1)}`
    if (this[apiMethod]) {
      return this[apiMethod](data)
    }

    console.warn(`${action} is not implemented`)
  }

  _registerApiHandler () {
    if (navigator && navigator.qt) {
      navigator.qt.onmessage = this._onMessage
      return
    }

    console.warn('No supported API found')
  }

  _sendApiMessage (action, data) {
    console.log({ action, data })
    if (navigator && navigator.qt) {
      return navigator.qt.postMessage(JSON.stringify({ action, data }))
    }

    console.error('No supported API found')
  }
}

export default new Api()
