/* globals describe,expect,jest,it,beforeEach,beforeAll,afterAll */

import registerApi from '../src/api'
import uuid from 'uuid/v4'

describe('api.js', () => {
  const editor = {
    getContent: jest.fn(),
    getFilePath: jest.fn(),
    loadFile: jest.fn(),
    onChange: jest.fn(),
    redo: jest.fn(),
    undo: jest.fn(),

    navigateDown: jest.fn(),
    navigateLeft: jest.fn(),
    navigateRight: jest.fn(),
    navigateUp: jest.fn()
  }

  const filePath = uuid()
  const content = uuid()

  describe('no supported API available', () => {
    it('should throw', () => {
      expect(registerApi).toThrow()
    })
  })

  describe('#navigator.qt API', () => {
    const postMessage = payload => {
      navigator.qt.onmessage({ data: JSON.stringify(payload) })
    }

    beforeEach(() => {
      navigator.qt = {
        onmessage: () => { },
        postMessage: jest.fn()
      }
    })

    describe('#registerApi', () => {
      it('should create API controller', () => {
        const apiController = registerApi()
        expect(navigator.qt.onmessage).toEqual(apiController._onMessage)
      })

      it('should not notify when app is loaded (notifyOnLoaded: false)', () => {
        registerApi()
        expect(navigator.qt.postMessage).toHaveBeenCalledTimes(0)
      })

      it('should notify when app is loaded (notifyOnLoaded: true)', () => {
        registerApi({ notifyOnLoaded: true })

        // Expect error message to be posted
        expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

        // Check for 'appLoaded' action
        const [message] = navigator.qt.postMessage.mock.calls[0]
        expect(JSON.parse(message).action).toEqual('appLoaded')
      })
    })

    describe('#loadFile', () => {
      it('should throw if `filePath` is missing', () => {
        registerApi({ editor })
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

      it('should execute action (readonly: false)', () => {
        registerApi({ editor })

        postMessage({
          action: 'loadFile',
          data: {
            filePath,
            content
          }
        })

        expect(editor.loadFile).toHaveBeenCalledWith(filePath, content, false)
      })

      it('should execute action (readonly: true)', () => {
        registerApi({ editor })

        postMessage({
          action: 'loadFile',
          data: {
            filePath,
            content,
            readOnly: true
          }
        })

        expect(editor.loadFile).toHaveBeenCalledWith(filePath, content, true)
      })
    })

    describe('#requestSaveFile', () => {
      it('should send API message with file content', () => {
        registerApi({ editor })
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
        registerApi({ editor })
        editor.getContent.mockReturnValue(content)
        editor.getFilePath.mockReturnValue(uuid())

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
        registerApi({ editor })
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
        registerApi({ editor })
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
        registerApi({ editor })
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
        registerApi({ editor })
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
        registerApi({ editor })
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
        registerApi({ editor })
        editor.getFilePath.mockReturnValue(filePath)

        postMessage({
          action: 'navigateDown',
          data: { filePath }
        })

        expect(editor.navigateDown).toHaveBeenCalledTimes(1)
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
        registerApi({ editor })
        editor.getFilePath.mockReturnValue(filePath)

        postMessage({ action: uuid() })
      })
    })
  })
})
