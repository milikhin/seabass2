/* globals describe, expect, it, localStorage */

import createApp from '../../src/app/app'
import { API_TRANSPORT } from '../../src/api/api-interface'
import { waitForSailfishApiMessage } from '../helpers/utils'

describe('SeabassApp', () => {
  it('should throw if API backend is  invalid', () => {
    const call = () => createApp({ apiTransport: 'invalid' })
    expect(call).toThrow()
  })

  it('should notify when app is loaded (SAILFISH_WEBVIEW)', async () => {
    const waitForApiMessage = waitForSailfishApiMessage()

    localStorage.setItem('sailfish__isToolbarOpened', true)
    createApp({ apiTransport: API_TRANSPORT.SAILFISH_WEBVIEW })

    // Check for 'appLoaded' action
    const evt = await waitForApiMessage
    expect(evt.detail.action).toEqual('appLoaded')
    expect(evt.detail.data).toEqual({
      isToolbarOpened: true,
      directory: null
    })
  })
})
