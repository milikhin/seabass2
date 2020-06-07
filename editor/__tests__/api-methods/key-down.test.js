/* globals describe, expect, it */
import { postMessage, createEditor } from '../helpers'

describe('#keyDown', () => {
  it('should execute `keyDown` action', () => {
    const { editor, cursorPosition, filePath } = createEditor()
    const keyCode = 39 // right arrow

    postMessage({
      action: 'keyDown',
      data: { filePath, keyCode }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: cursorPosition.column + 1
    })
  })
})
