import ace from 'ace-builds/src-noconflict/ace'
import modelist from 'ace-builds/src-noconflict/ext-modelist'

import 'ace-builds/webpack-resolver'
import 'ace-builds/src-noconflict/theme-twilight'
import beautify from 'ace-builds/src-noconflict/ext-beautify'

import { InvalidArgError } from './errors'

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

    this._onChangeTimer = undefined
    this._changeListeners = []
  }

  beautify () {
    beautify.beautify(this._ace.session)
  }

  /**
   * Returns editor content for the given file
   * @param {string} filePath - /path/to/file
   * @returns {string|undefined} - file content
   */
  getContent (filePath) {
    return this._ace.getValue()
  }

  getFilePath () {
    return this._filePath
  }

  /**
   * Load given content using given mode
   * @param {string} fileUrl - /path/to/file
   * @param {string} content - editor content
   * @returns {undefined}
   */
  loadFile (filePath, content, readOnly = false) {
    this._filePath = filePath
    const { mode } = modelist.getModeForPath(filePath)
    const editorSession = this._ace.getSession()

    this._ace.setOption('readOnly', readOnly)
    editorSession.setMode(mode)
    editorSession.off('change', this._onChange)
    this._ace.setValue(content)
    this._ace.clearSelection()
    editorSession.getUndoManager().reset()
    editorSession.on('change', this._onChange)
  }

  redo () {
    this._ace.redo()
  }

  undo () {
    this._ace.undo()
  }

  onChange (callback) {
    if (this._changeListeners.indexOf(callback) !== -1) {
      return
    }
    this._changeListeners.push(callback)
  }

  _onChange = () => {
    clearTimeout(this._onChangeTimer)
    this._onChangeTimer = setTimeout(() => {
      const undoManager = this._ace.getSession().getUndoManager()
      const data = {
        value: this._ace.getSession().getValue(),
        hasUndo: undoManager.hasUndo(),
        hasRedo: undoManager.hasRedo(),
        filePath: this._filePath
      }

      this._changeListeners.forEach(listener => listener(data))
    }, this._autosaveTimeout)
  }
}
