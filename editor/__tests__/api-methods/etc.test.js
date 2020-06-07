/* globals describe, beforeEach, afterEach, it, jest */
import { v4 as uuid } from 'uuid'
import { postMessage, createEditor } from '../helpers'

describe('#unknownMethod', () => {
  beforeEach(() => {
    console.warn = jest.fn()
  })

  afterEach(() => {
    console.warn.mockRestore()
  })

  it('should not throw', () => {
    createEditor()

    postMessage({ action: uuid() })
  })
})
