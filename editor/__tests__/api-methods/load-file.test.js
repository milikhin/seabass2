/* globals describe, expect, it */
import { v4 as uuid } from 'uuid'
import { postMessage, initDom } from '../helpers'
import registerApi from '../../src/api'
import editorFactory from '../../src/editor-factory'

describe('#loadFile', () => {
  let api, filePath, content
  const indentSize = 9 // cause why not?

  function setup ({ loadOptions = {} } = {}) {
    const { welcomeElem, rootElem } = initDom()
    const options = { editorFactory, welcomeElem, rootElem }
    api = registerApi(options)
    filePath = uuid()
    content = uuid()

    postMessage({
      action: 'loadFile',
      data: {
        filePath,
        content,
        ...loadOptions
      }
    })
  }

  it('should create editor with editable file', () => {
    setup()
    expect(api._tabsController._tabs).toHaveLength(1)

    const editor = api._tabsController._tabs[0].editor
    expect(editor._ace.getValue()).toEqual(content)
    expect(editor._ace.getOption('readOnly')).toEqual(false)
  })

  it('should set tab size = indent_size according to given editorConfig', () => {
    setup({
      loadOptions: {
        editorConfig: {
          indent_size: indentSize
        }
      }
    })
    expect(api._tabsController._tabs).toHaveLength(1)

    const editor = api._tabsController._tabs[0].editor
    expect(editor._ace.getOption('tabSize')).toEqual(indentSize)
  })

  it('should set tab size = tab_size according to given editorConfig', () => {
    setup({
      loadOptions: {
        editorConfig: {
          tab_width: indentSize
        }
      }
    })
    expect(api._tabsController._tabs).toHaveLength(1)

    const editor = api._tabsController._tabs[0].editor
    expect(editor._ace.getOption('tabSize')).toEqual(indentSize)
  })

  it('should create editor with readonly file', () => {
    setup({
      loadOptions: {
        readOnly: true
      }
    })
    expect(api._tabsController._tabs).toHaveLength(1)

    const editor = api._tabsController._tabs[0].editor
    expect(editor._ace.getValue()).toEqual(content)
    expect(editor._ace.getOption('readOnly')).toEqual(true)
  })

  it('should create Terminal window', () => {
    setup({
      loadOptions: {
        readOnly: true,
        isTerminal: true
      }
    })
    expect(api._tabsController._tabs).toHaveLength(1)

    const editor = api._tabsController._tabs[0].editor
    expect(editor._isTerminal).toEqual(true)
    expect(editor._ace.getValue()).toEqual(content)
    expect(editor._ace.getOption('showGutter')).toEqual(false)
    expect(editor._ace.getOption('showLineNumbers')).toEqual(false)
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
