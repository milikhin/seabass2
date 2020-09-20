/* globals describe, expect, it, beforeEach, afterEach, jest, localStorage */
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor } from '../helpers'

describe('#setPreferences', () => {
  beforeEach(() => {
    console.warn = jest.fn()
  })
  afterEach(() => {
    document.head.innerHTML = ''
  })

  it('should set dark theme', () => {
    const { editor, filePath } = createEditor()

    postMessage({
      action: 'setPreferences',
      data: { filePath, isDarkTheme: true }
    })

    expect(editor._ace.getTheme()).toEqual('ace/theme/twilight')
  })

  it('should set font size', () => {
    const { editor, filePath } = createEditor()
    const fontSize = 87

    postMessage({
      action: 'setPreferences',
      data: { filePath, fontSize }
    })

    expect(editor._ace.getFontSize()).toEqual(fontSize)
  })

  it('should save toolbar preferences to localStorage', () => {
    const { filePath } = createEditor()

    postMessage({
      action: 'setPreferences',
      data: { filePath, isSailfishToolbarOpened: true }
    })

    expect(localStorage.getItem('sailfish__isToolbarOpened')).toEqual('true')
  })

  it('should set theme colors', () => {
    const { filePath } = createEditor()

    document.head.innerHTML += `
      <style id="theme-css">
        /* CSS Custom Properties are not supported in Sailfish */
        /* these values are going to be replaces with JS: */
        body {
          /*background-color: #backgroungColor */
        }
        #welcome {
          /* color: #textColor */
        }
        #welcome a {
          /* color: #highlightColor */
        }
        .ace_tooltip.ace_doc-tooltip {
          /* background-color: #foregroundColor */
        }
        .ace_tooltip.ace_doc-tooltip {
          /* color: #foregroundText */
        }
        .ace_button,
        .ace_searchbtn,
        .ace_searchbtn:last-child,
        .ace_searchbtn_close,
        .ace_searchbtn_close:hover,
        .ace_search_field {
          /* background-color: #backgroungColor */
          /* color: #textColor */
          /* border-color: #borderColor */
        }
        .ace_button:hover,
        .ace_searchbtn:hover {
          /* background-color: #foregroundColor */
          /* color: #foregroundText */
        }
        .ace_search,
        .ace_button:hover::before {
          /* background-color: #foregroundColor */
          /* border-color: #borderColor */
          /* color: #textColor */
        }
       </style>
    `

    const colors = [
      uuid(),
      uuid(),
      uuid()
    ]
    postMessage({
      action: 'setPreferences',
      data: {
        filePath,
        textColor: colors[1],
        backgroundColor: colors[0],
        highlightColor: colors[2],
        borderColor: colors[2]
      }
    })

    const cssRules = document.getElementById('theme-css').sheet.cssRules
    expect(cssRules[0].style.backgroundColor).toEqual(colors[0])
    expect(cssRules[1].style.color).toEqual(colors[1])
    expect(cssRules[2].style.color).toEqual(colors[2])
    expect(cssRules[3].style.backgroundColor).toEqual(colors[0])
    expect(cssRules[4].style.color).toEqual(colors[1])
  })

  it('should ignore theme colors if <style> elem is not found', () => {
    const { filePath } = createEditor()
    postMessage({
      action: 'setPreferences',
      data: {
        filePath,
        textColor: uuid(),
        backgroundColor: uuid(),
        highlightColor: uuid()
      }
    })

    expect(console.warn).toHaveBeenCalledWith(
      'Theme colors are ignored as corresponding <style> tag is not found')
  })
})
