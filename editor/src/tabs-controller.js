import { NotFoundError } from './errors'

export default class TabsController {
  constructor ({ rootElem, editorFactory, onStateChange }) {
    this._editorFactory = editorFactory
    this._rootElem = rootElem
    this._tabs = []
    this._onStateChange = onStateChange
    this._preferences = {}
  }

  list () {
    return this._tabs
  }

  close (filePath) {
    const tabIndex = this._tabs.findIndex(({ filePath: tabFile }) => tabFile === filePath)
    if (tabIndex === -1) {
      return
    }

    this._tabs[tabIndex].editor.destroy()
    this._tabs.splice(tabIndex, 1)
  }

  /**
   * Creates a new tab with an editor
   * @param {string} filePath - /path/to/file
   * @param {string} [content=''] - file content
   * @param {Boolean} [readOnly=false] - true for a read only tab
   * @param {Boolean} [isSailfish=false] - true to apply SFOS-specific workarounds
   * @param {Boolean} [isTerminal=false] - true to apply Terminal-specific options
   * @param {Object} editorConfig - parsed EditorConfig options
   * @returns {Object} - tab description
   */
  create (options) {
    const {
      filePath,
      content = '',
      readOnly = false,
      isSailfish = false,
      isTerminal = false,
      doNotActivate = false,
      editorConfig = {}
    } = options
    const editorElem = document.createElement('div')
    editorElem.style.display = 'none'
    this._rootElem.appendChild(editorElem)
    editorElem.classList.add('editor')

    const tab = {
      filePath,
      editor: this._editorFactory({ elem: editorElem, editorConfig, isSailfish, isTerminal }),
      elem: editorElem,
      onStateChange: (state) => {
        this._onStateChange({ ...state, filePath })
      }
    }
    tab.editor.setPreferences(this._preferences)
    tab.editor.loadFile(filePath, content, readOnly)
    tab.editor.onChange(tab.onStateChange)

    this._tabs.push(tab)
    if (!doNotActivate) {
      this.show(filePath)
    }
    return tab
  }

  /**
   * Display tab corresponding to a given file
   * @param {string} filePath - /path/to/file
   * @returns {undefined}
   */
  show (filePath) {
    const tab = this._getTab(filePath)
    if (!tab) {
      return
    }

    this._tabs.forEach(({ elem, editor }) => {
      editor.deactivate()
      elem.style.display = 'none'
    })
    tab.elem.style.display = ''
    tab.editor.activate()
  }

  /**
   * Execute given action for the given file
   * @param {string} filePath - /path/to/file
   * @param {string} action - action to execute
   * @param {any[]} args - action params
   * @returns {any} action result
   */
  exec (filePath, action, ...args) {
    const tab = this._getTab(filePath)
    if (!tab) {
      throw new NotFoundError(`file ${filePath} is not loaded`)
    }
    return tab.editor[action](...args)
  }

  /**
   * Set preferences for all the tabs
   * @param {Boolean} isDarkTheme - true to set dark theme / false -- for a light one
   * @returns {undefined}
   */
  setPreferences (preferences) {
    this._preferences = preferences
    this._tabs.forEach(({ editor }) => {
      editor.setPreferences(preferences)
    })
  }

  _getTab (filePath) {
    const tabIndex = this._tabs.findIndex(({ filePath: tabFile }) => tabFile === filePath)
    if (tabIndex === -1) {
      return
    }
    return this._tabs[tabIndex]
  }
}
