/* globals describe, expect, it */

import { v4 as uuid } from 'uuid'
import Tabs from '../../src/tabs/tabs'

describe('Tabs', () => {
  const rootElem = document.createElement('div')

  describe('#create', () => {
    it('should create new tab', () => {
      const tabsPresenter = new Tabs({ rootElem })
      const tabId = uuid()

      const createdTab = tabsPresenter.create(tabId)

      expect(createdTab).toHaveProperty('id', tabId)
      expect(createdTab).toHaveProperty('elem')
    })
  })

  describe('#close', () => {
    it('should close the tab', () => {
      const tabsPresenter = new Tabs({ rootElem })
      const tabId = uuid()
      tabsPresenter._model._tabs.set(tabId, { id: tabId })

      tabsPresenter.close(tabId)

      expect(tabsPresenter._model._tabs.has(tabId)).toEqual(false)
    })
  })

  describe('#show', () => {
    it('should activate tab', () => {
      const tabsPresenter = new Tabs({ rootElem })
      const tabId = uuid()
      tabsPresenter._model._tabs.set(tabId, { id: tabId })

      tabsPresenter.show(tabId)

      expect(tabsPresenter._model._currentTabId).toEqual(tabId)
    })
  })

  describe('#currentTab', () => {
    it('should return current tab', () => {
      const tabsPresenter = new Tabs({ rootElem })
      const tabId = uuid()
      tabsPresenter._model._tabs.set(tabId, { id: tabId })
      tabsPresenter._model._currentTabId = tabId

      expect(tabsPresenter.currentTab).toEqual({ id: tabId })
    })
  })
})
