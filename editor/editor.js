import ace from 'ace-builds/src-noconflict/ace'
import modelist from 'ace-builds/src-noconflict/ext-modelist'

import 'ace-builds/webpack-resolver'
import 'ace-builds/src-noconflict/theme-twilight'
import beautify from 'ace-builds/src-noconflict/ext-beautify'

/**
 * Editor window
 */
export default class Editor {
  constructor ({ elem = 'root' } = {}) {
    this._ace = ace.edit(elem, {
      wrap: true,
      tabSize: 2,
      showFoldWidgets: false
    })

    this._ace.setTheme('ace/theme/twilight')
    this._ace.renderer.setOption('maxLines', Infinity)
    this._ace.renderer.setOption('minLines', 5)
    this._filePath = undefined
    this._changeTimeout = undefined
    this._changeListeners = []
    this._autosaveTimeout = 500
  }

  beautify () {
    beautify.beautify(this._ace.session)
  }

  /**
   * Load given content using given mode
   * @param {string} fileUrl - file url (path)
   * @param {string} content - editor content
   * @returns {undefined}
   */
  loadFile (filePath, content) {
    this._filePath = filePath
    const { mode } = modelist.getModeForPath(filePath)

    this._ace.getSession().off('change', this._onChange)
    this._ace.session.setMode(mode)
    this._ace.setValue(content)
    this._ace.clearSelection()

    this._ace.getSession().on('change', this._onChange)
  }

  onChange (callback) {
    if (this._changeListeners.indexOf(callback) !== -1) {
      return
    }
    this._changeListeners.push(callback)
  }

  _onChange = () => {
    clearTimeout(this._changeTimeout)
    const data = {
      value: this._ace.getSession().getValue(),
      filePath: this._filePath
    }

    this._changeTimeout = setTimeout(() => {
      this._changeListeners.forEach(listener => listener(data))
    }, this._autosaveTimeout)
  }
}
