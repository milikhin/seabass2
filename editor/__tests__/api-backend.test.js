/* globals describe, expect, it, localStorage */

import registerApi from '../src/api'
import { InvalidArgError } from '../src/errors'
import editorFactory from './helpers/mocks/editor-factory'

describe('#registerApi', () => {
  it('should throw when `editorFactory` is undefined', () => {
    // sut = system under test
    const sutCall = () => registerApi()
    expect(sutCall).toThrow(InvalidArgError)
  })

  it('should register message handlers (`navigatorQt` backend)', () => {
    const apiController = registerApi({ editorFactory, apiBackend: 'navigatorQt' })
    expect(navigator.qt.onmessage).toEqual(apiController._handleQtMessage)
    expect(window.postSeabassApiMessage).toBe(undefined)
  })

  it('should register message handlers (`url` backend)', () => {
    const apiController = registerApi({ editorFactory, apiBackend: 'url' })
    expect(window.postSeabassApiMessage).toEqual(apiController._onMessage)
    expect(navigator.qt.onmessage).toBe(undefined)
  })

  it('should throw if API backend is invalid', () => {
    const sutCall = () => registerApi({ editorFactory, apiBackend: 'incorrect' })
    expect(sutCall).toThrow(InvalidArgError)
  })

  it('should not notify when app is loaded (notifyOnLoaded: false)', () => {
    registerApi({ editorFactory })
    expect(navigator.qt.postMessage).toHaveBeenCalledTimes(0)
  })

  it('should notify when app is loaded (notifyOnLoaded: true)', () => {
    registerApi({ editorFactory, notifyOnLoaded: true })

    expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

    // Check for 'appLoaded' action
    const [message] = navigator.qt.postMessage.mock.calls[0]
    expect(JSON.parse(message).action).toEqual('appLoaded')
    expect(JSON.parse(message).data).toEqual({
      isSailfishToolbarOpened: undefined
    })
  })

  it('should notify when app is loaded (`url` backend)', () => {
    registerApi({ editorFactory, notifyOnLoaded: true, apiBackend: 'url' })

    // Check for 'appLoaded' action
    const payload = { action: 'appLoaded', data: {} }
    expect(window.location.assign).toHaveBeenCalledTimes(1)
    expect(window.location.assign).toHaveBeenCalledWith(`http://seabass/${encodeURIComponent(JSON.stringify(payload))}`)
  })

  it('should notify when app is loaded (notifyOnLoaded: true, toolbar opened)', () => {
    localStorage.setItem('sailfish__isToolbarOpened', true)
    registerApi({ editorFactory, notifyOnLoaded: true })

    expect(navigator.qt.postMessage).toHaveBeenCalledTimes(1)

    // Check for 'appLoaded' action
    const [message] = navigator.qt.postMessage.mock.calls[0]
    expect(JSON.parse(message).action).toEqual('appLoaded')
    expect(JSON.parse(message).data).toEqual({
      isSailfishToolbarOpened: true
    })
  })
})
