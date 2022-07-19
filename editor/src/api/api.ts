import {
  ApiTransport,
  API_TRANSPORT,
  IncomingApiMessage,
  IncomingMessagePayload
} from './api-interface'
import SailfishApiTransport from './sailfish-transport'
import SocketApiTransport from './socket-transport'

/** Outgoing API message to a platform-specific app */
interface OutgoingApiMessage {
  action: string
  data: unknown
}

interface ApiOptions {
  /** Platform-specific API transport name */
  transport: API_TRANSPORT
}

type SeabassApiEvent<T extends keyof IncomingMessagePayload> = CustomEvent<IncomingMessagePayload[T]>
type SeabassApiEventListener<T extends keyof IncomingMessagePayload> = ((evt: SeabassApiEvent<T>) => void) |
({ handleEvent: (evt: SeabassApiEvent<T>) => void }) | null

export default class SeabassApi extends EventTarget {
  _socket?: WebSocket
  /** Platform-specific API transport name */
  _transport: ApiTransport

  SUPPORTED_TRANSPORTS = {
    [API_TRANSPORT.SAILFISH_WEBVIEW]: SailfishApiTransport,
    [API_TRANSPORT.WEB_SOCKET]: SocketApiTransport
  }

  /** supported incoming API messages */
  EVENTS = new Set([
    'closeFile',
    'fileSaved',
    'keyDown',
    'loadFile',
    'oskVisibilityChanged',
    'openFile',
    'redo',
    'requestFileSave',
    'setPreferences',
    'setSailfishPreferences',
    'toggleReadOnly',
    'undo',
    'viewportChange'
  ])

  constructor ({ transport }: ApiOptions) {
    super()

    if (this.SUPPORTED_TRANSPORTS[transport] === undefined) {
      throw new Error(`API transport '${transport}' is not supported`)
    }

    const Transport = this.SUPPORTED_TRANSPORTS[transport]
    this._transport = new Transport(this._onMessage.bind(this))
  }

  addEventListener<T extends keyof IncomingMessagePayload>(type: T,
    callback: SeabassApiEventListener<T>, options?: EventListenerOptions): void {
    super.addEventListener(type, callback as EventListenerOrEventListenerObject | null, options)
  }

  /**
   * Sends error message to the platform-specific app
   * @param message error message to send
   */
  sendError (message: string): void {
    this.send({ action: 'error', data: { message } })
  }

  /**
   * Sends logs to the platform-specific app
   * @param message logs to send
   */
  sendLogs = (message: unknown): void => {
    this.send({ action: 'log', data: { message } })
  }

  /** Sends API message */
  send ({ action, data }: OutgoingApiMessage): void {
    this._transport.send({ action, data })
  }

  _onMessage ({ action, data }: IncomingApiMessage<keyof IncomingMessagePayload>): void {
    if (!this.EVENTS.has(action)) {
      return this.sendLogs(`Event ${action} is not supported`)
    }

    const evt = new CustomEvent(action, { detail: data })
    this.dispatchEvent(evt)
  }
}
