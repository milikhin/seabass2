/* globals describe, expect, it */

import { v4 as uuid } from 'uuid'
import SeabassApi from '../../src/api/api'
import { API_TRANSPORT } from '../../src/api/api-interface'
import { waitForSailfishApiMessage } from '../helpers/utils'

describe('SeabassApi', () => {
  describe('#constructor', () => {
    it('should throw if API transport is missing', () => {
      const call = () => new SeabassApi({})
      expect(call).toThrow()
    })

    it('should throw if API backend is invalid', () => {
      const call = () => new SeabassApi({ transport: 'invalid' })
      expect(call).toThrow()
    })

    it('should register API message handler', () => {
      /* eslint-disable-next-line no-new */
      new SeabassApi({ transport: API_TRANSPORT.SAILFISH_WEBVIEW })
      expect(window.postSeabassApiMessage).toBeTruthy()
    })
  })

  describe('window.postSeabassApiMessage', () => {
    it('should handle supported events', async () => {
      const data = uuid()
      const api = new SeabassApi({ transport: API_TRANSPORT.SAILFISH_WEBVIEW })
      const action = Array.from(api.EVENTS)[0]
      const waitForEvent = new Promise(resolve => api.addEventListener(action, resolve))

      window.postSeabassApiMessage({ action, data })

      const evt = await waitForEvent
      expect(evt.detail).toEqual(data)
    })

    it('should warn about unsupported events', async () => {
      const action = uuid()
      const data = uuid()
      const waitForApiMessage = waitForSailfishApiMessage()

      // eslint-disable-next-line no-unused-vars
      const api = new SeabassApi({ transport: API_TRANSPORT.SAILFISH_WEBVIEW })

      window.postSeabassApiMessage({ action, data })

      const logsEvt = await waitForApiMessage
      expect(logsEvt.detail.action).toEqual('log')
    })
  })

  describe('#send', () => {
    it('should send API messages (SAILFISH_WEBVIEW)', async () => {
      const action = uuid()
      const data = uuid()
      const waitForApiMessage = waitForSailfishApiMessage()

      const api = new SeabassApi({ transport: API_TRANSPORT.SAILFISH_WEBVIEW })
      api.send({ action, data })

      // check that corresponding event fired
      const evt = await waitForApiMessage
      expect(evt.detail.action).toEqual(action)
      expect(evt.detail.data).toEqual(data)
    })
  })

  describe('#sendLogs', () => {
    it('should send given logs', async () => {
      const data = uuid()
      const waitForApiMessage = waitForSailfishApiMessage()

      const api = new SeabassApi({ transport: API_TRANSPORT.SAILFISH_WEBVIEW })
      api.sendLogs(data)

      const evt = await waitForApiMessage
      expect(evt.detail.action).toEqual('log')
      expect(evt.detail.data).toEqual({ message: data })
    })
  })

  describe('#sendError', () => {
    it('should send given error message', async () => {
      const data = uuid()
      const waitForApiMessage = waitForSailfishApiMessage()

      const api = new SeabassApi({ transport: API_TRANSPORT.SAILFISH_WEBVIEW })
      api.sendError(data)

      const evt = await waitForApiMessage
      expect(evt.detail.action).toEqual('error')
      expect(evt.detail.data).toEqual({ message: data })
    })
  })
})
