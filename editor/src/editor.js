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
      showFoldWidgets: false,
      indentedSoftWrap: false,
      animatedScroll: false
    })
    this._filePath = undefined
    this._onChangeTimer = undefined
    this._changeListeners = []
    this._lastScrollTop = 0

    this._ace.setTheme('ace/theme/twilight')
    this._applyPlatformHaks()
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
    editorSession.off('change', this._onChange)
    this._ace.setOption('readOnly', readOnly)

    // load new content and activate required mode
    this._ace.setValue(content)
    editorSession.setMode(mode)
    this._ace.clearSelection()
    editorSession.getUndoManager().reset()

    editorSession.on('change', this._onChange)
    this._onChange()
  }

  navigateDown () {
    // 1. Position cursor
    this._ace.navigateDown()
    // 2. Scroll editor into the current cursor position
    this._ace.renderer.scrollCursorIntoView()
  }

  navigateLeft () {
    this._ace.navigateLeft()
  }

  navigateRight () {
    this._ace.navigateRight()
  }

  navigateUp () {
    this._ace.navigateUp()
    this._ace.renderer.scrollCursorIntoView()
  }

  navigateFileEnd () {
    this._ace.navigateFileEnd()
    this._ace.renderer.scrollCursorIntoView()
  }

  navigateFileStart () {
    this._ace.navigateFileStart()
    this._ace.renderer.scrollCursorIntoView()
  }

  navigateLineEnd () {
    this._ace.navigateLineEnd()
  }

  navigateLineStart () {
    this._ace.navigateLineStart()
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

  toggleReadOnly () {
    const readOnly = this._ace.getOption('readOnly')
    this._ace.setOption('readOnly', !readOnly)
    this._onChange()
  }

  _applyPlatformHaks () {
    this._ace.getSession().on('changeScrollTop', scrollTop => {
      if (this._lastScrollTop > scrollTop) {
        window.scrollTo(0, 1)
      } else {
        window.scrollTo(0, 0)
      }

      this._lastScrollTop = scrollTop
    })
  }

  _onChange = () => {
    clearTimeout(this._onChangeTimer)
    this._onChangeTimer = setTimeout(() => {
      const undoManager = this._ace.getSession().getUndoManager()
      const data = {
        value: this._ace.getSession().getValue(),
        hasUndo: undoManager.hasUndo(),
        hasRedo: undoManager.hasRedo(),
        isReadOnly: this._ace.getOption('readOnly'),
        filePath: this._filePath
      }

      this._changeListeners.forEach(listener => listener(data))
    }, this._autosaveTimeout)
  }
}
