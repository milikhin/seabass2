/* globals beforeEach, describe, expect, it */

import { v4 as uuid } from 'uuid'
import TabsModel from '../../src/tabs/model'
import TabsView from '../../src/tabs/view'

function createTab (view, tabId) {
  view._model._tabs.set(tabId, {
    id: tabId,
    elem: document.createElement('div')
  })
  const tabElem = document.createElement('div')
  view._contentElems.set(tabId, tabElem)
  view._rootElem.appendChild(tabElem)
  return tabElem
}

describe('TabsView', () => {
  const rootElem = document.createElement('div')
  const model = new TabsModel()

  describe('oncreate handler', () => {
    it('should create new tab content element', () => {
      const view = new TabsView({ rootElem, model })
      const tabId = uuid()

      model.create(tabId)

      const elem = view._contentElems.get(tabId)

      expect(elem).toBeTruthy()
      expect(elem.tagName).toEqual('DIV')
    })

    it('should append new tab content element as a root child', () => {
      const view = new TabsView({ rootElem, model })
      const tabId = uuid()

      model.create(tabId)

      const elem = view._contentElems.get(tabId)
      expect(rootElem.contains(elem)).toBeTruthy()
    })
  })

  describe('onclose handler', () => {
    const tabId = uuid()
    let view
    let tabElem

    beforeEach(() => {
      view = new TabsView({ rootElem, model })
      tabElem = createTab(view, tabId)
    })

    it('should delete tab\'s content element', () => {
      model.close(tabId)

      expect(view._contentElems.has(tabId)).toEqual(false)
      expect(rootElem.contains(tabElem)).toEqual(false)
    })
  })

  describe('onshow/onhide handlers', () => {
    const prevTabId = uuid()
    const currentTabId = uuid()
    let view
    let prevTabElem
    let currentTabElem

    beforeEach(() => {
      view = new TabsView({ rootElem, model })
      prevTabElem = createTab(view, prevTabId)
      currentTabElem = createTab(view, currentTabId)
      model._currentTabId = prevTabId
    })

    it('should make active tab\'s content element visible', () => {
      currentTabElem.style.display = 'none'
      model.show(currentTabId)

      expect(currentTabElem.style.display).toEqual('')
    })

    it('should make previous tab\'s content element hidden', () => {
      prevTabElem.style.display = ''

      model.show(currentTabId)

      expect(prevTabElem.style.display).toEqual('none')
    })
  })
})
