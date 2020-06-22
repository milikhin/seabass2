/* globals describe, expect, it */
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor, testFilePathRequired } from '../helpers'

describe('#openFile', () => {
  it('should activate tab', () => {
    const { api, editor, filePath } = createEditor()
    api._tabsController.create({ filePath: uuid() })

    postMessage({
      action: 'openFile',
      data: { filePath }
    })

    expect(editor._editorElem.style.display).toEqual('')
  })

  it('should throw if `filePath` is missing', () => {
    testFilePathRequired('openFile')
  })
})
