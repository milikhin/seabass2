import { IncomingApiMessage, IncomingMessagePayload } from './api/api'
import { API_TRANSPORT } from './api/api-interface'
import createApp from './app/app'

declare global {
  interface Window {
    /** `postSeabassApiMessage` global function is used to communicate with UI */
    postSeabassApiMessage: <T extends keyof IncomingMessagePayload>(msg: IncomingApiMessage<T>) => void
    /** app configuration */
    seabassOptions: {
      /** API transport name */
      apiBackend: API_TRANSPORT
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
      apiBackend: window.seabassOptions.apiBackend,
      rootElem,
      welcomeElem
    })
  })
})
