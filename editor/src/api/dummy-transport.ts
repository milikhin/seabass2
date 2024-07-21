import { ApiTransport, IncomingApiMessage, IncomingMessagePayload } from './api-interface'

export default class DummyTransport implements ApiTransport {
  constructor (onMessage: (message: IncomingApiMessage<keyof IncomingMessagePayload>) => void) {
    window.postSeabassApiMessage = onMessage
  }

  send (message: Record<string, unknown>): void {
    console.log(message)
  }
}
