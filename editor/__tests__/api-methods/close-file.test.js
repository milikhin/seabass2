/* globals describe, expect, it */
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor, testFilePathRequired } from '../helpers'

describe('#closeFile', () => {
  it('should throw if `filePath` is missing', () => {
    testFilePathRequired('closeFile')
  })

  it('should close existing tab', () => {
    const { api, filePath } = createEditor()
    postMessage({
      action: 'closeFile',
      data: { filePath }
    })

    expect(api._tabsController._tabs).toHaveLength(0)
  })

  it('should detach completer', async () => {
    const { editor } = createEditor()
    editor._ace.setValue('sentense with spaces ')
    editor._ace.execCommand('startAutocomplete')
    const autocompleteWindow = document.querySelector('.ace_autocomplete')

    // guard assertion: expect autocomplete window to be displayed
    expect(autocompleteWindow).not.toBeNull()
    expect(autocompleteWindow.style.display).not.toEqual('none')

    // simulate opening a new tab!
    postMessage({
      action: 'loadFile',
      data: { filePath: uuid(), content: '' }
    })

    // check that autocomplete window is closed
    const closedAutocompleteWindow = document.querySelector('.ace_autocomplete')
    expect(closedAutocompleteWindow.style.display).toEqual('none')
  })
})
