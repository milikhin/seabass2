/* globals describe, expect, it, beforeEach, afterEach, jest */
import { postMessage, createEditor } from '../helpers'
describe('#toggleSearch', () => {
  const originalSetInterval = setTimeout

  beforeEach(() => {
    console.warn = jest.fn()
  })

  afterEach(() => {
    window.setInterval = originalSetInterval
  })

  it('should display search bar', () => {
    const { editor, filePath } = createEditor()
    window.setInterval = callback => callback()

    postMessage({
      action: 'toggleSearch',
      data: { filePath }
    })

    expect(editor._ace.container.querySelector('.ace_search')).toBeTruthy()
  })

  it.skip('should set focus to editor when search bar clicked', () => {
    const { editor, filePath } = createEditor()
    window.setInterval = callback => callback()
    editor._ace.focus = jest.fn()

    postMessage({
      action: 'toggleSearch',
      data: { filePath }
    })
    editor._ace.container.querySelector('.ace_search').click()
    expect(editor._ace.focus).toHaveBeenCalled()
  })
})
