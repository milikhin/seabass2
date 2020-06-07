/* globals describe, expect, it */
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor } from '../helpers'

describe('#undo/#redo', () => {
  it('should `undo` changes', () => {
    const content = uuid()
    const { editor, filePath } = createEditor({ content })
    editor._ace.setValue(uuid())

    postMessage({
      action: 'undo',
      data: { filePath }
    })

    expect(editor._ace.getValue()).toEqual(content)
  })

  it('should `redo` changes', () => {
    const { editor, filePath } = createEditor()
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
