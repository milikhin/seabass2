/* globals describe,expect,jest,it,beforeEach,beforeAll,afterAll,afterEach,localStorage */

import registerApi from '../src/api'
import { NotFoundError } from '../src/errors'
import { v4 as uuid } from 'uuid'
import editorFactory from '../src/editor-factory'
import md5 from 'blueimp-md5'

describe('editor API', () => {
  const filePath = uuid()
  const content = uuid()
  const welcomeElem = document.createElement('div')
  const rootElem = document.createElement('div')

  const postMessage = payload => {
    navigator.qt.onmessage({ data: JSON.stringify(payload) })
  }

  const createEditor = (options = {}) => {
    const { apiBackend = 'navigatorQt', multiLine = false, moveToEnd = false } = options
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
      cursorPosition: editor._ace.getCursorPosition()
    }
  }

  beforeEach(() => {
    navigator.qt = {
      postMessage: jest.fn()
    }
  })

  describe('#closeFile', () => {
    it('should throw if `filePath` is missing', () => {
      registerApi({ editorFactory })
      postMessage({
        action: 'closeFile',
        data: {}
      })

      // Expect error message to be posted
      expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

      // Check for 'error' action
      const [errorMessage] = navigator.qt.postMessage.mock.calls[0]
      expect(JSON.parse(errorMessage).action).toEqual('error')
    })

    it('should close existing tab', () => {
      const { api } = createEditor()
      const filePath = api._tabsController._tabs[0].filePath
      postMessage({
        action: 'closeFile',
        data: { filePath }
      })

      expect(api._tabsController._tabs).toHaveLength(0)
    })
  })

  describe('#fileSaved', () => {
    it('should set initial content hash', () => {
      const { editor } = createEditor()
      const newContent = uuid()

      postMessage({
        action: 'fileSaved',
        data: { filePath, content: newContent }
      })

      const newContentHash = md5(newContent)
      expect(editor._initialContentHash).toEqual(newContentHash)
    })
  })

  describe('#openFile', () => {
    it('should activate tab', () => {
      const { api, editor } = createEditor()
      api._tabsController.create(uuid())

      postMessage({
        action: 'openFile',
        data: { filePath }
      })

      expect(editor._editorElem.style.display).toEqual('')
    })

    it('should throw if `filePath` is missing', () => {
      registerApi({ editorFactory })
      postMessage({
        action: 'openFile',
        data: {}
      })

      // Expect error message to be posted
      expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

      // Check for 'error' action
      const [errorMessage] = navigator.qt.postMessage.mock.calls[0]
      expect(JSON.parse(errorMessage).action).toEqual('error')
    })
  })

  describe('#loadFile', () => {
    it('should create editor with editable file', () => {
      const api = registerApi({ editorFactory, welcomeElem, rootElem })

      postMessage({
        action: 'loadFile',
        data: {
          filePath,
          content
        }
      })
      expect(api._tabsController._tabs).toHaveLength(1)

      const editor = api._tabsController._tabs[0].editor
      expect(editor._ace.getValue()).toEqual(content)
      expect(editor._ace.getOption('readOnly')).toEqual(false)
    })

    it('should create editor with readonly file', () => {
      const api = registerApi({ editorFactory, welcomeElem, rootElem })

      postMessage({
        action: 'loadFile',
        data: {
          filePath,
          content,
          readOnly: true
        }
      })

      expect(api._tabsController._tabs).toHaveLength(1)

      const editor = api._tabsController._tabs[0].editor
      expect(editor._ace.getValue()).toEqual(content)
      expect(editor._ace.getOption('readOnly')).toEqual(true)
    })

    it('should throw if `filePath` is missing', () => {
      registerApi({ editorFactory })
      const content = uuid()

      postMessage({
        action: 'loadFile',
        data: { content }
      })

      // Expect error message to be posted
      expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

      // Check for 'error' action
      const [errorMessage] = navigator.qt.postMessage.mock.calls[0]
      expect(JSON.parse(errorMessage).action).toEqual('error')
    })
  })

  describe('#requestSaveFile', () => {
    it('should send API message with file content', () => {
      createEditor()
      postMessage({
        action: 'requestSaveFile',
        data: { filePath }
      })

      // Expect 'saveFile' message to be sent
      expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

      // Check for 'saveFile' action with correct payload
      const [message] = navigator.qt.postMessage.mock.calls[0]
      const { action, data } = JSON.parse(message)
      expect(action).toEqual('saveFile')
      expect(data).toEqual({ filePath, content, responseTo: 'requestSaveFile' })
    })

    it('should throw API error if `filePath` is incorrect', () => {
      createEditor()
      postMessage({
        action: 'requestSaveFile',
        data: { filePath: uuid() }
      })

      // Expect 'saveFile' message to be sent
      expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

      // Check for 'error' action
      const [errorMessage] = navigator.qt.postMessage.mock.calls[0]
      expect(JSON.parse(errorMessage).action).toEqual('error')
    })
  })

  describe('#undo/#redo', () => {
    it('should `undo` changes', () => {
      const { editor } = createEditor()
      editor._ace.setValue(uuid())

      postMessage({
        action: 'undo',
        data: { filePath }
      })

      expect(editor._ace.getValue()).toEqual(content)
    })

    it('should `redo` changes', () => {
      const { editor } = createEditor()
      const newContent = uuid()
      editor._ace.setValue(newContent)

      postMessage({
        action: 'undo',
        data: { filePath }
      })
      postMessage({
        action: 'redo',
        data: { filePath }
      })

      expect(editor._ace.getValue()).toEqual(newContent)
    })
  })

  describe('#navigateLeft', () => {
    it('should execute `navigateLeft` action', () => {
      const { editor, cursorPosition } = createEditor({ moveToEnd: true })

      postMessage({
        action: 'navigateLeft',
        data: { filePath }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: cursorPosition.row,
        column: cursorPosition.column - 1
      })
    })
  })

  describe('#navigateRight', () => {
    it('should execute `navigateRight` action', () => {
      const { editor, cursorPosition } = createEditor()

      postMessage({
        action: 'navigateRight',
        data: { filePath }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: cursorPosition.row,
        column: cursorPosition.column + 1
      })
    })
  })

  describe('#navigateUp', () => {
    it('should execute `navigateUp` action', () => {
      const { editor, cursorPosition } = createEditor({ multiLine: true, moveToEnd: true })

      postMessage({
        action: 'navigateUp',
        data: { filePath }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: cursorPosition.row - 1,
        column: cursorPosition.column
      })
    })
  })

  describe('#navigateDown', () => {
    it('should execute `navigateDown` action', () => {
      const { editor, cursorPosition } = createEditor({ multiLine: true })

      postMessage({
        action: 'navigateDown',
        data: { filePath }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: cursorPosition.row + 1,
        column: cursorPosition.column
      })
    })
  })

  describe('#navigateLineStart', () => {
    it('should execute `navigateLineStart` action', () => {
      const { editor, cursorPosition } = createEditor({ moveToEnd: true })

      postMessage({
        action: 'navigateLineStart',
        data: { filePath }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: cursorPosition.row,
        column: 0
      })
    })
  })

  describe('#navigateLineEnd', () => {
    it('should execute `navigateLineEnd` action', () => {
      const { editor, cursorPosition } = createEditor()

      postMessage({
        action: 'navigateLineEnd',
        data: { filePath }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: cursorPosition.row,
        column: content.length
      })
    })
  })

  describe('#navigateFileStart', () => {
    it('should execute `navigateFileStart` action', () => {
      const { editor } = createEditor({ multiLine: true, moveToEnd: true })

      postMessage({
        action: 'navigateFileStart',
        data: { filePath }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: 0,
        column: 0
      })
    })
  })

  describe('#navigateFileEnd', () => {
    it('should execute `navigateFileEnd` action', () => {
      const { editor } = createEditor({ multiLine: true })

      postMessage({
        action: 'navigateFileEnd',
        data: { filePath }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: content.split('\n').length - 1,
        column: content.length
      })
    })
  })

  describe('#keyDown', () => {
    it('should execute `keyDown` action', () => {
      const { editor, cursorPosition } = createEditor()
      const keyCode = 39 // right arrow

      postMessage({
        action: 'keyDown',
        data: { filePath, keyCode }
      })

      expect(editor._ace.getCursorPosition()).toEqual({
        row: cursorPosition.row,
        column: cursorPosition.column + 1
      })
    })
  })

  describe('#setPreferences', () => {
    beforeEach(() => {
      console.warn = jest.fn()
    })
    afterEach(() => {
      document.head.innerHTML = ''
    })

    it('should set dark theme', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'setPreferences',
        data: { filePath, isDarkTheme: true }
      })

      expect(editor._ace.getTheme()).toEqual('ace/theme/twilight')
    })

    it('should save toolbar preferences to localStorage', () => {
      registerApi({ editorFactory })

      postMessage({
        action: 'setPreferences',
        data: { filePath, isSailfishToolbarOpened: true }
      })

      expect(localStorage.getItem('sailfish__isToolbarOpened')).toEqual('true')
    })

    it('should set theme colors', () => {
      registerApi({ editorFactory })
      document.head.innerHTML += `
        <style id="theme-css">
          /* CSS Custom Properties are not supported in Sailfish */
          /* these values are replaceable via JS */
          body {
            background-color: #eee; /* backgroungColor */
          }
          #welcome {
            color: #111; /* textColor */
          }
          #welcome a {
            color: dodgerblue; /* linkColor */
          }
          .ace_tooltip.ace_doc-tooltip {
            background-color: #eee; /* foregroundColor */
          }
          .ace_tooltip.ace_doc-tooltip {
            color: #111; /* foregroundText */
          }
        </style>
      `

      const colors = [
        uuid(),
        uuid(),
        uuid()
      ]
      postMessage({
        action: 'setPreferences',
        data: {
          filePath,
          textColor: colors[1],
          backgroundColor: colors[0],
          linkColor: colors[2]
        }
      })

      const cssRules = document.getElementById('theme-css').sheet.cssRules
      expect(cssRules[0].style.backgroundColor).toEqual(colors[0])
      expect(cssRules[1].style.color).toEqual(colors[1])
      expect(cssRules[2].style.color).toEqual(colors[2])
      expect(cssRules[3].style.backgroundColor).toEqual(colors[0])
      expect(cssRules[4].style.color).toEqual(colors[1])
    })

    it('should ignore theme colors if <style> elem is not found', () => {
      registerApi({ editorFactory })
      postMessage({
        action: 'setPreferences',
        data: {
          filePath,
          textColor: uuid(),
          backgroundColor: uuid(),
          linkColor: uuid()
        }
      })

      expect(console.warn).toHaveBeenCalledWith('Theme colors are ignored as corresponding <style> tag is not found')
    })
  })

  describe('#toggleReadOnly', () => {
    beforeEach(() => {
      console.warn = jest.fn()
    })

    it('should execute `toggleReadOnly` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'toggleReadOnly',
        data: { filePath }
      })

      expect(editor._ace.getReadOnly()).toEqual(true)
    })

    it('should not throw if filePath is incorrect', () => {
      const { editor } = createEditor()
      const invalidFilePath = uuid()

      postMessage({
        action: 'toggleReadOnly',
        data: { filePath: invalidFilePath }
      })

      expect(console.warn).toBeCalledWith(expect.any(NotFoundError))
      expect(editor._ace.getReadOnly()).toEqual(false)
    })
  })

  describe('#getFileContent', () => {
    it('should return file content', () => {
      createEditor({ apiBackend: 'url' })
      const value = window.postSeabassApiMessage({
        action: 'getFileContent',
        data: { filePath }
      })

      expect(value).toEqual(content)
    })
  })

  describe('#unknownMethod', () => {
    beforeAll(() => {
      console.warn = jest.fn()
    })

    afterAll(() => {
      console.warn.mockRestore()
    })

    it('should not throw', () => {
      createEditor()

      postMessage({ action: uuid() })
    })
  })
})
