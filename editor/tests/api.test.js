/* globals describe,expect,jest,it,beforeEach */

import registerApi from '../src/api'
import uuid from 'uuid/v4'

describe('api.js', () => {
  const editor = {
    getContent: jest.fn(),
    loadFile: jest.fn()
  }

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

    it('should create API controller', () => {
      const apiController = registerApi()
      expect(navigator.qt.onmessage).toEqual(apiController._onMessage)
    })

    it('#loadFile: should throw if `filePath` is missing', () => {
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

    it('#loadFile: should execute action', () => {
      registerApi({ editor })
      const filePath = uuid()
      const content = uuid()

      postMessage({
        action: 'loadFile',
        data: {
          filePath,
          content
        }
      })

      expect(editor.loadFile).toHaveBeenCalledWith(filePath, content)
    })

    it('#requestSaveFile: should send API message with file content', () => {
      registerApi({ editor })
      const filePath = uuid()
      const content = uuid()
      editor.getContent.mockReturnValue(content)

      postMessage({
        action: 'requestSaveFile',
        data: {
          filePath
        }
      })

      // Expect 'saveFile' message to be sent
      expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

      // Check for 'saveFile' action with correct payload
      const [message] = navigator.qt.postMessage.mock.calls[0]
      const { action, data } = JSON.parse(message)
      expect(action).toEqual('saveFile')
      expect(data).toEqual({ filePath, content })
    })
  })
})
