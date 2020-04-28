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
    if (this._filePath !== filePath) {
      throw new InvalidArgError(`file ${filePath} is not loaded`)
    }

    return this._ace.getValue()
  }

  /**
   * Load given content using given mode
   * @param {string} fileUrl - /path/to/file
   * @param {string} content - editor content
   * @returns {undefined}
   */
  loadFile (filePath, content) {
    this._filePath = filePath
    const { mode } = modelist.getModeForPath(filePath)
    this._ace.session.setMode(mode)
    this._ace.setValue(content)
    this._ace.clearSelection()
  }
}
