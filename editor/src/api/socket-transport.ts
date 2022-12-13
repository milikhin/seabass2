import { ApiTransport, IncomingApiMessage, IncomingMessagePayload } from './api-interface'

export default class SocketApiTransport implements ApiTransport {
  _socket: WebSocket

  INIT_TIMEOUT = 100

  constructor (onMessage: (message: IncomingApiMessage<keyof IncomingMessagePayload>) => void) {
    const query = new URLSearchParams(location.search)
    const socketPort = query.get('socketPort')
    if (socketPort === null) {
      throw new Error('Web Socket port is required for SocketApiTransport')
    }

    this._socket = new WebSocket(`ws://127.0.0.1:${socketPort}`)
    this._socket.onmessage = evt => {
      onMessage(JSON.parse(evt.data))
    }
  }

  send (message: Record<string, unknown>): void {
    switch (this._socket.readyState) {
      case WebSocket.OPEN:
        this._socket.send(JSON.stringify(message))
        break
      case WebSocket.CONNECTING:
        setTimeout(() => this.send(message), this.INIT_TIMEOUT)
        break
      default:
        console.warn('websocket is closed / being closed')
    }
  }
}
