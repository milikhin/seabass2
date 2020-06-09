/* globals describe, expect, it */
import { v4 as uuid } from 'uuid'
import { createEditor } from '../helpers'

describe('#onStateChanged', () => {
  it('should emit \'onStateChanged\' event when editor\'s content changed', async () => {
    const { editor, filePath } = createEditor()
    editor._ace.setValue(uuid())

    navigator.qt.postMessage.mockReset()
    await new Promise(resolve => setTimeout(resolve, 250 /* onchange timeout */))

    const calls = navigator.qt.postMessage.mock.calls
      .map(argsJson => JSON.parse(argsJson))
      .filter(({ data }) => filePath === data.filePath)

    // guard asserion: expect single onchange event
    expect(calls).toHaveLength(1)
    expect(calls[0]).toEqual({
      action: 'stateChanged',
      data: {
        hasChanges: true,
        hasUndo: true,
        hasRedo: false,
        filePath,
        isReadOnly: false
      }
    })
  })
})
