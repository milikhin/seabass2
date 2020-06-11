/* globals expect */

import { v4 as uuid } from 'uuid'
import registerApi from '../../src/api'
import editorFactory from '../../src/editor-factory'

export const initDom = () => {
  const welcomeElem = document.getElementById('welcome')
  const rootElem = document.getElementById('root')

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

export const testFilePathRequired = actionName => {
  createEditor()
  postMessage({
    action: actionName,
    data: {}
  })

  // Expect error message to be posted
  expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

  // Check for 'error' action
  const [errorMessage] = navigator.qt.postMessage.mock.calls[0]
  expect(JSON.parse(errorMessage).action).toEqual('error')
}
