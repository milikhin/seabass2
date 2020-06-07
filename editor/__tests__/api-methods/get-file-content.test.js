/* globals describe, expect, it */
import { v4 as uuid } from 'uuid'
import { createEditor } from '../helpers'

describe('#getFileContent', () => {
  it('should return file content', () => {
    const content = uuid()
    const { filePath } = createEditor({ apiBackend: 'url', content })
    const value = window.postSeabassApiMessage({
      action: 'getFileContent',
      data: { filePath }
    })

    expect(value).toEqual(content)
  })
})
