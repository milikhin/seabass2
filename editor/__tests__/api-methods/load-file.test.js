/* globals describe, expect, it, beforeEach */
import { v4 as uuid } from 'uuid'
import { postMessage, initDom } from '../helpers'
import registerApi from '../../src/api'
import editorFactory from '../../src/editor-factory'

describe('#loadFile', () => {
  let api, filePath, content

  beforeEach(() => {
    const { welcomeElem, rootElem } = initDom()
    api = registerApi({ editorFactory, welcomeElem, rootElem })
    filePath = uuid()
    content = uuid()
  })

  it('should create editor with editable file', () => {
    postMessage({
      action: 'loadFile',
      data: {
        filePath,
        content
      }
    })
    expect(api._tabsController._tabs).toHaveLength(1)

    const editor = api._tabsController._tabs[0].editor
    expect(editor._ace.getValue()).toEqual(content)
    expect(editor._ace.getOption('readOnly')).toEqual(false)
  })

  it('should create editor with readonly file', () => {
    postMessage({
      action: 'loadFile',
      data: {
        filePath,
        content,
        readOnly: true
      }
    })

    expect(api._tabsController._tabs).toHaveLength(1)

    const editor = api._tabsController._tabs[0].editor
    expect(editor._ace.getValue()).toEqual(content)
    expect(editor._ace.getOption('readOnly')).toEqual(true)
  })

  it('should throw if `filePath` is missing', () => {
    registerApi({ editorFactory })

    postMessage({
      action: 'loadFile',
      data: { content }
    })

    // Expect error message to be posted
    expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

    // Check for 'error' action
    const [errorMessage] = navigator.qt.postMessage.mock.calls[0]
    expect(JSON.parse(errorMessage).action).toEqual('error')
  })
})
