import { InvalidArgError } from './errors'

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

  create (filePath, content = '', readOnly = false) {
    const editorElem = document.createElement('div')
    this._rootElem.appendChild(editorElem)
    editorElem.classList.add('editor')

    const tab = {
      filePath,
      editor: this._editorFactory({ elem: editorElem }),
      elem: editorElem,
      onStateChange: (state) => {
        this._onStateChange({ ...state, filePath })
      }
    }
    tab.editor.setPreferences(this._preferences)
    tab.editor.loadFile(filePath, content, readOnly)
    tab.editor.onChange(tab.onStateChange)

    this._tabs.push(tab)
    this.show(filePath)
    return tab
  }

  show (filePath) {
    const tab = this._getTab(filePath)
    if (!tab) {
      return
    }

    this._tabs.forEach(({ elem }) => {
      elem.style.display = 'none'
    })
    tab.elem.style.display = ''
    tab.editor.activate()
  }

  exec (filePath, action, ...args) {
    const tab = this._getTab(filePath)
    return tab.editor[action](...args)
  }

  setPreferences (preferences) {
    this._tabs.forEach(({ editor }) => {
      editor.setPreferences(preferences)
    })
  }

  _getTab (filePath) {
    const tabIndex = this._tabs.findIndex(({ filePath: tabFile }) => tabFile === filePath)
    if (tabIndex === -1) {
      throw new InvalidArgError(`file ${filePath} is not loaded`)
    }
    return this._tabs[tabIndex]
  }
}
