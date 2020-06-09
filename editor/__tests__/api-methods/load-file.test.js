/* globals describe, expect, it, beforeEach */
import { v4 as uuid } from 'uuid'
import { postMessage, initDom } from '../helpers'
import registerApi from '../../src/api'
import editorFactory from '../../src/editor-factory'

describe('#loadFile', () => {
  let api, filePath, content

  function setup ({ isSailfish } = {}) {
    const { welcomeElem, rootElem } = initDom()
    const options = { editorFactory, welcomeElem, rootElem }
    if (isSailfish) {
      options.isSailfish = isSailfish
    }
    api = registerApi(options)
    filePath = uuid()
    content = uuid()
  }

  it('should create editor with editable file', () => {
    setup()
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
    setup()
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

  it('should apply SailfishOS workarounds if required', () => {
    setup({ isSailfish: true })
    postMessage({
      action: 'loadFile',
      data: {
        filePath,
        content
      }
    })
    expect(api._tabsController._tabs).toHaveLength(1)

    const editor = api._tabsController._tabs[0].editor
    expect(editor._isSailfish).toEqual(true)
  })

  it('should add scrollTop debouncer as a SailfishOS workaround', async () => {
    setup({ isSailfish: true })
    postMessage({
      action: 'loadFile',
      data: {
        filePath,
        content
      }
    })
    const editor = api._tabsController._tabs[0].editor
    editor._ace.session._emit('changeScrollTop')
    editor._ace.session._emit('changeScrollTop')
    expect(window.scrollTo).toHaveBeenCalledTimes(1)

    await new Promise(resolve => setTimeout(resolve, 100))
    editor._ace.session._emit('changeScrollTop')
    expect(window.scrollTo).toHaveBeenCalledTimes(2)
  })

  it('should throw if `filePath` is missing', () => {
    setup()
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
