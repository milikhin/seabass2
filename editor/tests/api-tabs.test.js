/* globals describe,expect,jest,it,beforeEach,beforeAll,afterAll,localStorage */

import registerApi from '../src/api' //eslint-disable-line
import uuid from 'uuid/v4'//eslint-disable-line
import editorFactory from './mocks/editor-factory'

describe('editor API', () => {
  const filePath = uuid()
  const content = uuid()
  const welcomeElem = document.createElement('div')
  const rootElem = document.createElement('div')

  const postMessage = payload => {
    navigator.qt.onmessage({ data: JSON.stringify(payload) })
  }

  const createEditor = () => {
    const api = registerApi({ editorFactory, rootElem, welcomeElem })
    api._tabsController.create(filePath)
    const editor = api._tabsController._tabs[0].editor
    editor.getContent.mockReturnValue(content)
    editor.getFilePath.mockReturnValue(uuid())
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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

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
      editor.getFilePath.mockReturnValue(filePath)

      postMessage({
        action: 'navigateFileEnd',
        data: { filePath }
      })

      expect(editor.navigateFileEnd).toHaveBeenCalledTimes(1)
    })
  })

  describe('#setPreferences', () => {
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
  })

  describe('#toggleReadOnly', () => {
    it('should execute `toggleReadOnly` action', () => {
      const { editor } = createEditor()
      editor.getFilePath.mockReturnValue(filePath)

      postMessage({
        action: 'toggleReadOnly',
        data: { filePath }
      })

      expect(editor.toggleReadOnly).toHaveBeenCalledTimes(1)
    })
  })

  describe('#getFileContent', () => {
    it('should execute `getContent` action', () => {
      const { editor } = createEditor()
      editor.getFilePath.mockReturnValue(filePath)

      postMessage({
        action: 'getFileContent',
        data: { filePath }
      })

      expect(editor.getContent).toHaveBeenCalledTimes(1)
    })
  })

  describe('#unknownMethod', () => {
    const originalConsoleWarn = console.warn
    beforeAll(() => {
      console.warn = jest.fn()
    })

    afterAll(() => {
      console.warn = originalConsoleWarn
    })

    it('should not throw', () => {
      const { editor } = createEditor()
      editor.getFilePath.mockReturnValue(filePath)

      postMessage({ action: uuid() })
    })
  })
})
