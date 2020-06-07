/* globals describe, expect, it */
import { postMessage, createEditor } from '../helpers'

describe('#closeFile', () => {
  it('should throw if `filePath` is missing', () => {
    createEditor()
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
    const { api, filePath } = createEditor()
    postMessage({
      action: 'closeFile',
      data: { filePath }
    })

    expect(api._tabsController._tabs).toHaveLength(0)
  })
})
