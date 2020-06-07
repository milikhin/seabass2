/* globals describe, expect, it */
import { postMessage, createEditor } from '../helpers'

describe('#navigateLeft', () => {
  it('should execute `navigateLeft` action', () => {
    const { editor, cursorPosition, filePath } = createEditor({ moveToEnd: true })

    postMessage({
      action: 'navigateLeft',
      data: { filePath }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: cursorPosition.column - 1
    })
  })
})

describe('#navigateRight', () => {
  it('should execute `navigateRight` action', () => {
    const { editor, cursorPosition, filePath } = createEditor()

    postMessage({
      action: 'navigateRight',
      data: { filePath }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: cursorPosition.column + 1
    })
  })
})

describe('#navigateUp', () => {
  it('should execute `navigateUp` action', () => {
    const { editor, cursorPosition, filePath } = createEditor({ multiLine: true, moveToEnd: true })

    postMessage({
      action: 'navigateUp',
      data: { filePath }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row - 1,
      column: cursorPosition.column
    })
  })
})

describe('#navigateDown', () => {
  it('should execute `navigateDown` action', () => {
    const { editor, cursorPosition, filePath } = createEditor({ multiLine: true })

    postMessage({
      action: 'navigateDown',
      data: { filePath }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row + 1,
      column: cursorPosition.column
    })
  })
})

describe('#navigateLineStart', () => {
  it('should execute `navigateLineStart` action', () => {
    const { editor, cursorPosition, filePath } = createEditor({ moveToEnd: true })

    postMessage({
      action: 'navigateLineStart',
      data: { filePath }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: 0
    })
  })
})

describe('#navigateLineEnd', () => {
  it('should execute `navigateLineEnd` action', () => {
    const { editor, cursorPosition, filePath } = createEditor()
    const content = editor._ace.getValue()
    postMessage({
      action: 'navigateLineEnd',
      data: { filePath }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: content.length
    })
  })
})

describe('#navigateFileStart', () => {
  it('should execute `navigateFileStart` action', () => {
    const { editor, filePath } = createEditor({ multiLine: true, moveToEnd: true })

    postMessage({
      action: 'navigateFileStart',
      data: { filePath }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: 0,
      column: 0
    })
  })
})

describe('#navigateFileEnd', () => {
  it('should execute `navigateFileEnd` action', () => {
    const { editor, filePath } = createEditor({ multiLine: true })
    const content = editor._ace.getValue()

    postMessage({
      action: 'navigateFileEnd',
      data: { filePath }
    })

    const rowsNumber = content.split('\n').length
    expect(editor._ace.getCursorPosition()).toEqual({
      row: rowsNumber - 1,
      column: content.split('\n')[rowsNumber - 1].length
    })
  })
})
