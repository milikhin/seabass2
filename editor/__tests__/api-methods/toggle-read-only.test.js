/* globals describe, expect, it, beforeEach, jest */
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor } from '../helpers'
import { NotFoundError } from '../../src/errors'
describe('#toggleReadOnly', () => {
  beforeEach(() => {
    console.warn = jest.fn()
  })

  it('should execute `toggleReadOnly` action', () => {
    const { editor, filePath } = createEditor()

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
