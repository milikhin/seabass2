import { v4 as uuid } from 'uuid'
import registerApi from '../src/api'
import editorFactory from '../src/editor-factory'

export const initDom = () => {
  const welcomeElem = document.createElement('div')
  const rootElem = document.createElement('div')

  return { welcomeElem, rootElem }
}

export const postMessage = payload => {
  navigator.qt.onmessage({ data: JSON.stringify(payload) })
}

export const createEditor = (options = {}) => {
  const {
    apiBackend = 'navigatorQt',
    multiLine = false,
    moveToEnd = false,
    content = uuid()
  } = options
  const { welcomeElem, rootElem } = initDom()
  const filePath = uuid()

  const api = registerApi({ editorFactory, apiBackend, rootElem, welcomeElem })
  api._tabsController.create(
    filePath,
    multiLine ? `${content}\n${content}\n${content}` : content
  )
  const editor = api._tabsController._tabs[0].editor
  if (moveToEnd) {
    editor.navigateFileEnd()
  } else {
    editor.navigateFileStart()
  }
  return {
    api,
    editor,
    filePath,
    cursorPosition: editor._ace.getCursorPosition()
  }
}
