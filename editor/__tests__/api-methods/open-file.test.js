/* globals describe, expect, it */
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor } from '../helpers'
describe('#openFile', () => {
  it('should activate tab', () => {
    const { api, editor, filePath } = createEditor()
    api._tabsController.create(uuid())

    postMessage({
      action: 'openFile',
      data: { filePath }
    })

    expect(editor._editorElem.style.display).toEqual('')
  })

  it('should throw if `filePath` is missing', () => {
    createEditor()
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
