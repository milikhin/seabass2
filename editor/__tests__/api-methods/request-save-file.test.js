/* globals describe, expect, it */
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor } from '../helpers'

describe('#requestSaveFile', () => {
  it('should send API message with file content', () => {
    const content = uuid()
    const { filePath } = createEditor({ content })
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
