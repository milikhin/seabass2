/* globals describe, expect, it */
import { postMessage, createEditor } from '../helpers'

describe('#navigate(left)', () => {
  it('should execute `navigate left` action', () => {
    const { editor, cursorPosition, filePath } = createEditor({ moveToEnd: true })

    postMessage({
      action: 'navigate',
      data: { filePath, where: 'left' }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: cursorPosition.column - 1
    })
  })
})

describe('#navigate(right)', () => {
  it('should execute `navigate right` action', () => {
    const { editor, cursorPosition, filePath } = createEditor()

    postMessage({
      action: 'navigate',
      data: { filePath, where: 'right' }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: cursorPosition.column + 1
    })
  })
})

describe('#navigate(up)', () => {
  it('should execute `navigate up` action', () => {
    const { editor, cursorPosition, filePath } = createEditor({ multiLine: true, moveToEnd: true })

    postMessage({
      action: 'navigate',
      data: { filePath, where: 'up' }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row - 1,
      column: cursorPosition.column
    })
  })
})

describe('#navigate(down)', () => {
  it('should execute `navigateDown` action', () => {
    const { editor, cursorPosition, filePath } = createEditor({ multiLine: true })

    postMessage({
      action: 'navigate',
      data: { filePath, where: 'down' }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row + 1,
      column: cursorPosition.column
    })
  })
})

describe('#navigate(lineStart)', () => {
  it('should execute `navigate to line start` action', () => {
    const { editor, cursorPosition, filePath } = createEditor({ moveToEnd: true })

    postMessage({
      action: 'navigate',
      data: { filePath, where: 'lineStart' }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: 0
    })
  })
})

describe('#navigate(lineEnd)', () => {
  it('should execute `navigate to line end` action', () => {
    const { editor, cursorPosition, filePath } = createEditor()
    const content = editor._ace.getValue()
    postMessage({
      action: 'navigate',
      data: { filePath, where: 'lineEnd' }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: cursorPosition.row,
      column: content.length
    })
  })
})

describe('#navigate(fileStart)', () => {
  it('should execute `navigate to file start` action', () => {
    const { editor, filePath } = createEditor({ multiLine: true, moveToEnd: true })

    postMessage({
      action: 'navigate',
      data: { filePath, where: 'fileStart' }
    })

    expect(editor._ace.getCursorPosition()).toEqual({
      row: 0,
      column: 0
    })
  })
})

describe('#navigate(fileEnd)', () => {
  it('should execute `navigate to file end` action', () => {
    const { editor, filePath } = createEditor({ multiLine: true })
    const content = editor._ace.getValue()

    postMessage({
      action: 'navigate',
      data: { filePath, where: 'fileEnd' }
    })

    const rowsNumber = content.split('\n').length
    expect(editor._ace.getCursorPosition()).toEqual({
      row: rowsNumber - 1,
      column: content.split('\n')[rowsNumber - 1].length
    })
  })
})
