/* globals describe, expect, it */
import md5 from 'blueimp-md5'
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor } from '../helpers'

describe('#fileSaved', () => {
  it('should set initial content hash', () => {
    const { editor, filePath } = createEditor()
    const newContent = uuid()

    postMessage({
      action: 'fileSaved',
      data: { filePath, content: newContent }
    })

    const newContentHash = md5(newContent)
    expect(editor._initialContentHash).toEqual(newContentHash)
  })
})
