/* globals describe, expect, beforeEach, it */

import { v4 as uuid } from 'uuid'
import TabsModel from '../../src/tabs/model'

describe('TabsModel', () => {
  const id = uuid()
  let model

  beforeEach(() => {
    model = new TabsModel()
  })

  describe('#create', () => {
    it('should create new tab with given ID', () => {
      const tab = model.create(id)

      expect(tab).toHaveProperty('id', id)
      expect(tab).toHaveProperty('elem')
    })

    it('should dispatch event', async () => {
      const evtPromise = new Promise(resolve => model.addEventListener('create', resolve))
      const tab = model.create(id)

      const evt = await evtPromise
      expect(evt.detail).toEqual(tab)
    })
  })

  describe('#close', () => {
    it('should close tab with given ID', () => {
      model._tabs.set(id, { id })

      model.close(id)

      expect(model._tabs.has(id)).toEqual(false)
    })

    it('should ignore inexisting tabs', () => {
      const tab = { id }
      model._tabs.set(id, tab)

      model.close(uuid())

      expect(model._tabs).toEqual(new Map([[id, tab]]))
    })

    it('should dispatch event', async () => {
      const tab = { id }
      model._tabs.set(id, tab)
      const evtPromise = new Promise(resolve => model.addEventListener('close', resolve))

      model.close(id)

      const evt = await evtPromise
      expect(evt.detail).toEqual(tab)
    })
  })

  describe('#get', () => {
    it('should return tab by ID', () => {
      const tab0 = { id }
      const tab1 = { id: uuid() }
      model._tabs.set(tab0.id, tab0)
      model._tabs.set(tab1.id, tab1)

      expect(model.get(tab0.id)).toEqual(tab0)
    })
  })

  describe('#list', () => {
    it('should return array of tabs', () => {
      const tab0 = { id }
      const tab1 = { id: uuid() }

      model._tabs.set(tab0.id, tab0)
      model._tabs.set(tab1.id, tab1)

      expect(model.list).toEqual([tab0, tab1])
    })
  })

  describe('#show', () => {
    it('should activate tab with given ID', () => {
      const tab0 = { id }
      const tab1 = { id: uuid() }
      model._tabs.set(tab0.id, tab0)
      model._tabs.set(tab1.id, tab1)
      model._currentTabId = tab0.id

      model.show(tab1.id)

      expect(model._currentTabId).toEqual(tab1.id)
    })

    it('should ignore inexisting tab IDs', () => {
      const tab = { id }
      model._tabs.set(tab.id, tab)
      model._currentTabId = id

      model.show(uuid())

      expect(model._currentTabId).toEqual(tab.id)
    })
  })

  describe('#currentTab', () => {
    it('should return currently active tab', () => {
      const tab = { id }
      model._tabs.set(tab.id, tab)
      model._currentTabId = tab.id

      expect(model.currentTab).toEqual(tab)
    })

    it('should return undefined if there are no active tab', () => {
      const tab = { id }
      model._tabs.set(tab.id, tab)

      expect(model.currentTab).toBeUndefined()
    })

    it('should return undefined if active tab not exists', () => {
      model._currentTabId = uuid()

      expect(model.currentTab).toBeUndefined()
    })
  })
})
