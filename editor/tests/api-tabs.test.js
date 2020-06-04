/* globals describe,expect,jest,it,beforeEach,beforeAll,afterAll,afterEach,localStorage */

import registerApi from '../src/api'
import { NotFoundError } from '../src/errors'
import { v4 as uuid } from 'uuid'
import editorFactory from './mocks/editor-factory'

describe('editor API', () => {
  const filePath = uuid()
  const content = uuid()
  const welcomeElem = document.createElement('div')
  const rootElem = document.createElement('div')

  const postMessage = payload => {
    navigator.qt.onmessage({ data: JSON.stringify(payload) })
  }

  const createEditor = (apiBackend = 'navigatorQt') => {
    const api = registerApi({ editorFactory, apiBackend, rootElem, welcomeElem })
    api._tabsController.create(filePath)
    const editor = api._tabsController._tabs[0].editor
    editor.getContent.mockReturnValue(content)
    return { api, editor }
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
    it('should execute `setSavedContent` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'fileSaved',
        data: { filePath }
      })

      expect(editor.setSavedContent).toHaveBeenCalledTimes(1)
    })
  })

  describe('#openFile', () => {
    it('should execute `setSavedContent` action', () => {
      const { api, editor } = createEditor()
      api._tabsController.create(uuid())
      editor.activate.mockReset()

      postMessage({
        action: 'openFile',
        data: { filePath }
      })

      expect(editor.activate).toHaveBeenCalledTimes(1)
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
    it('should throw if `filePath` is missing', () => {
      registerApi({ editorFactory })
      const content = uuid()

      postMessage({
        action: 'loadFile',
        data: {
          content
        }
      })

      // Expect error message to be posted
      expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

      // Check for 'error' action
      const [errorMessage] = navigator.qt.postMessage.mock.calls[0]
      expect(JSON.parse(errorMessage).action).toEqual('error')
    })

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
      expect(api._tabsController._tabs[0].editor.loadFile).toHaveBeenCalledWith(filePath, content, false)
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
      expect(api._tabsController._tabs[0].editor.loadFile).toHaveBeenCalledWith(filePath, content, true)
    })
  })

  describe('#requestSaveFile', () => {
    it('should send API message with file content', () => {
      const { editor } = createEditor()
      editor.getContent.mockReturnValue(content)

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
      const { api, editor } = createEditor()
      editor.getContent.mockReturnValue(content)
      api._tabsController._tabs[0].filePath = uuid()

      postMessage({
        action: 'requestSaveFile',
        data: { filePath }
      })

      // Expect 'saveFile' message to be sent
      expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

      // Check for 'error' action
      const [errorMessage] = navigator.qt.postMessage.mock.calls[0]
      expect(JSON.parse(errorMessage).action).toEqual('error')
    })
  })

  describe('#undo', () => {
    it('should execute `undo` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'undo',
        data: { filePath }
      })

      expect(editor.undo).toHaveBeenCalledTimes(1)
    })
  })

  describe('#redo', () => {
    it('should execute `redo` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'redo',
        data: { filePath }
      })

      expect(editor.redo).toHaveBeenCalledTimes(1)
    })
  })

  describe('#navigateLeft', () => {
    it('should execute `navigateLeft` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'navigateLeft',
        data: { filePath }
      })

      expect(editor.navigateLeft).toHaveBeenCalledTimes(1)
    })
  })

  describe('#navigateRight', () => {
    it('should execute `navigateRight` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'navigateRight',
        data: { filePath }
      })

      expect(editor.navigateRight).toHaveBeenCalledTimes(1)
    })
  })

  describe('#navigateUp', () => {
    it('should execute `navigateUp` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'navigateUp',
        data: { filePath }
      })

      expect(editor.navigateUp).toHaveBeenCalledTimes(1)
    })
  })

  describe('#navigateDown', () => {
    it('should execute `navigateDown` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'navigateDown',
        data: { filePath }
      })

      expect(editor.navigateDown).toHaveBeenCalledTimes(1)
    })
  })

  describe('#navigateLineStart', () => {
    it('should execute `navigateLineStart` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'navigateLineStart',
        data: { filePath }
      })

      expect(editor.navigateLineStart).toHaveBeenCalledTimes(1)
    })
  })

  describe('#navigateLineEnd', () => {
    it('should execute `navigateLineEnd` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'navigateLineEnd',
        data: { filePath }
      })

      expect(editor.navigateLineEnd).toHaveBeenCalledTimes(1)
    })
  })

  describe('#navigateFileStart', () => {
    it('should execute `navigateFileStart` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'navigateFileStart',
        data: { filePath }
      })

      expect(editor.navigateFileStart).toHaveBeenCalledTimes(1)
    })
  })

  describe('#navigateFileEnd', () => {
    it('should execute `navigateFileEnd` action', () => {
      const { editor } = createEditor()

      postMessage({
        action: 'navigateFileEnd',
        data: { filePath }
      })

      expect(editor.navigateFileEnd).toHaveBeenCalledTimes(1)
    })
  })

  describe('#keyDown', () => {
    it('should execute `keyDown` action', () => {
      const { editor } = createEditor()
      const keyCode = uuid()

      postMessage({
        action: 'keyDown',
        data: { filePath, keyCode }
      })

      expect(editor.keyDown).toHaveBeenCalledTimes(1)
      expect(editor.keyDown).toHaveBeenCalledWith(keyCode)
    })
  })

  describe('#setPreferences', () => {
    beforeEach(() => {
      console.warn = jest.fn()
    })
    afterEach(() => {
      document.body.innerHTML = ''
    })

    it('should execute `setPreferences` action', () => {
      const { editor } = createEditor()

      editor.setPreferences.mockReset()
      postMessage({
        action: 'setPreferences',
        data: { filePath }
      })

      expect(editor.setPreferences).toHaveBeenCalledTimes(1)
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
      document.body.innerHTML = `
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

      expect(editor.toggleReadOnly).toHaveBeenCalledTimes(1)
    })

    it('should not throw if filePath is incorrect', () => {
      const { editor } = createEditor()
      const invalidFilePath = uuid()

      postMessage({
        action: 'toggleReadOnly',
        data: { filePath: invalidFilePath }
      })

      expect(console.warn).toBeCalledWith(expect.any(NotFoundError))
      expect(editor.toggleReadOnly).toHaveBeenCalledTimes(0)
    })
  })

  describe('#getFileContent', () => {
    it('should execute `getContent` action', () => {
      const { editor } = createEditor('url')
      const expectedValue = uuid()
      editor.getContent.mockReturnValue(expectedValue)

      const value = window.postSeabassApiMessage({
        action: 'getFileContent',
        data: { filePath }
      })

      expect(value).toEqual(expectedValue)
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
