import { ApiTransport, IncomingApiMessage, IncomingMessagePayload } from './api-interface'

export default class SailfishApiTransport implements ApiTransport {
  constructor (onMessage: (message: IncomingApiMessage<keyof IncomingMessagePayload>) => void) {
    window.postSeabassApiMessage = onMessage
  }

  send (message: Record<string, unknown>): void {
    document.dispatchEvent(new CustomEvent('framescript:action', {
      detail: message
    }))
  }
}
