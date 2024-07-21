import { API_TRANSPORT, IncomingApiMessage, IncomingMessagePayload } from './api/api-interface'
import createApp from './app/app'

if (window.seabassOptions.useWebUi) {
  import('./web-ui')
}

declare global {
  interface Window {
    /** `postSeabassApiMessage` global function is used to communicate with UI */
    postSeabassApiMessage: <T extends keyof IncomingMessagePayload>(msg: IncomingApiMessage<T>) => void
    /** app configuration */
    seabassOptions: {
      /** API transport name */
      apiTransport: API_TRANSPORT
      useWebUi: boolean
    }
  }
}

window.addEventListener('DOMContentLoaded', () => {
  const rootElem = document.getElementById('root')
  const welcomeElem = document.getElementById('welcome')
  if ((rootElem == null) || (welcomeElem == null)) {
    return console.error('App can\'t be initialized as required HTML elements are not found')
  }

  // use timeout to ensure that platform-specific API transport has been initialized first
  setTimeout(() => {
    createApp({
      apiTransport: window.seabassOptions.apiTransport,
      rootElem,
      welcomeElem
    })
  })
})
