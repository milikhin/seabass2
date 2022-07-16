/* globals describe, expect, jest, it, localStorage, CustomEvent */

import { v4 as uuid } from 'uuid'
import SeabassAppModel from '../../src/app/model'
import Editor from '../../src/editor/editor'

describe('SeabassAppModel', () => {
  describe('#constructor', () => {
    it('should set default preferences', () => {
      localStorage.setItem('sailfish__isToolbarOpened', true)
      const model = new SeabassAppModel()

      expect(model._editors).toEqual(new Map())
      expect(model._preferences).toEqual({
        isDarkTheme: false
      })
      expect(model._viewport).toEqual({
        verticalHtmlOffset: 0
      })
      expect(model.sailfishPreferences).toEqual({ isToolbarOpened: true })
    })
  })

  describe('#loadFile', () => {
    const options = {
      content: uuid(),
      editorConfig: { indent_size: 1, tab_width: 1 },
      filePath: uuid(),
      isReadOnly: false
    }

    it('should open new Editor', () => {
      const model = new SeabassAppModel()
      model.loadFile(options, document.createElement('div'))

      const newEditor = model._editors.get(options.filePath)
      expect(newEditor).toBeInstanceOf(Editor)
    })

    it('should dispatch loadFile event', async () => {
      const model = new SeabassAppModel()
      const evtPromise = new Promise(resolve => model.addEventListener('loadFile', resolve))
      model.loadFile(options, document.createElement('div'))

      const evt = await evtPromise
      expect(evt.detail).toEqual(options)
    })

    it('should dispatch stateChange event', async () => {
      const model = new SeabassAppModel()
      const evtPromise = new Promise(resolve => model.addEventListener('stateChange', resolve))
      model.loadFile(options, document.createElement('div'))

      const evt = await evtPromise
      expect(evt.detail).toEqual({
        hasChanges: false,
        hasUndo: false,
        hasRedo: false,
        isReadOnly: options.isReadOnly
      })
    })
  })

  describe('#closeFile', () => {
    const filePath = uuid()
    const editor = { destroy: jest.fn() }

    it('should close Editor', () => {
      const model = new SeabassAppModel()
      model._editors.set(filePath, editor)
      model.closeFile(filePath)

      expect(model._editors.has(filePath)).toBe(false)
    })

    it('should dispatch closeFile event', async () => {
      const model = new SeabassAppModel()
      model._editors.set(filePath, editor)
      const evtPromise = new Promise(resolve => model.addEventListener('closeFile', resolve))
      model.closeFile(filePath)

      const evt = await evtPromise
      expect(evt.detail).toEqual({ filePath })
    })

    it('should ignore incorrect file paths', async () => {
      const model = new SeabassAppModel()
      model._editors.set(filePath, editor)
      model.closeFile(uuid())

      expect(model._editors).toEqual(new Map([[filePath, editor]]))
    })
  })

  describe('#getContent', () => {
    const filePath = uuid()
    const expectedContent = uuid()
    const editor = { getContent: () => expectedContent }

    it('should return editor content', () => {
      const model = new SeabassAppModel()
      model._editors.set(filePath, editor)

      const content = model.getContent(filePath)
      expect(content).toEqual(expectedContent)
    })

    it('should throw if file path is invalid', async () => {
      const model = new SeabassAppModel()

      const call = () => model.getContent(uuid())

      expect(call).toThrow()
    })
  })

  describe('#forwardEvent', () => {
    const filePath = uuid()
    const action = uuid()
    const editor = { [action]: jest.fn() }

    it('should call corresponding editor method', () => {
      const model = new SeabassAppModel()
      model._editors.set(filePath, editor)

      const args = { foo: uuid() }
      model.forwardEvent(filePath, new CustomEvent(action, { detail: args }))

      expect(editor[action]).toHaveBeenCalledWith(args)
    })

    it('should do nothing if file path is invalid', async () => {
      const model = new SeabassAppModel()
      const args = { foo: uuid() }
      model.forwardEvent(uuid(), new CustomEvent(action, { detail: args }))

      expect(editor[action]).toHaveBeenCalledTimes(0)
    })
  })

  describe('#setPreferences', () => {
    it('should set HTML theme preferences', () => {
      const model = new SeabassAppModel()

      const options = {
        backgroundColor: uuid(),
        textColor: uuid(),
        highlightColor: uuid()
      }
      model.setPreferences(options)

      expect(model._htmlTheme).toEqual({
        backgroundColor: options.backgroundColor,
        textColor: options.textColor,
        highlightColor: options.highlightColor
      })
    })

    it('should set app preferences', () => {
      const model = new SeabassAppModel()

      const options = {
        isDarkTheme: true
      }
      model.setPreferences(options)

      expect(model._preferences).toEqual({
        isDarkTheme: options.isDarkTheme
      })
    })
  })

  describe('#setViewportOptions', () => {
    it('should set viewport options', () => {
      const model = new SeabassAppModel()

      const options = {
        verticalHtmlOffset: Math.random()
      }
      model.setViewportOptions(options)

      expect(model._viewport).toEqual({
        verticalHtmlOffset: options.verticalHtmlOffset
      })
    })
  })

  describe('#setSailfishPreferences', () => {
    it('should set toolbar visibility', () => {
      const model = new SeabassAppModel()

      const options = { isToolbarOpened: true }
      model.setSailfishPreferences(options)

      expect(model._sailfish).toEqual({
        isToolbarOpened: options.isToolbarOpened
      })
    })
  })
})
