import { InputPreferences, SeabassSailfishPreferences, ViewportOptions } from '../app/model'
import { KeyDownOptions } from '../editor/editor'
import {
  API_TRANSPORT,
  FileActionOptions,
  FileLoadOptions
} from './api-interface'

/** possible payload of API messages */
export interface IncomingMessagePayload {
  closeFile: FileActionOptions
  fileSaved: undefined
  keyDown: KeyDownOptions
  viewportChange: ViewportOptions
  loadFile: FileLoadOptions
  openFile: FileActionOptions
  oskVisibilityChanged: undefined
  redo: undefined
  requestFileSave: FileActionOptions
  setPreferences: InputPreferences
  setSailfishPreferences: SeabassSailfishPreferences
  undo: undefined
  toggleReadOnly: undefined
}

/** Incoming API message from a platform-specific app */
export interface IncomingApiMessage<T extends keyof IncomingMessagePayload> {
  action: T
  data: IncomingMessagePayload[T]
}

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
  _transport: API_TRANSPORT

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

    if (!Object.values(API_TRANSPORT).includes(transport)) {
      throw new Error(`Given API transport '${transport}' is not supported`)
    }

    this._transport = transport
    this._initTransport()
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
    const payload = JSON.stringify({ action, data })
    switch (this._transport) {
      case API_TRANSPORT.SAILFISH_WEBVIEW: {
        const evt = new CustomEvent('framescript:action', {
          detail: { action, data }
        })
        document.dispatchEvent(evt)
        return
      }
      case API_TRANSPORT.URL_HANDLER: {
        return this._socket?.send(payload)
      }
    }
  }

  _initTransport (): void {
    switch (this._transport) {
      case API_TRANSPORT.SAILFISH_WEBVIEW:
        window.postSeabassApiMessage = this._onMessage.bind(this)
        return
      case API_TRANSPORT.URL_HANDLER:
        this._socket = new WebSocket('ws://127.0.0.1:55222')
        this._socket.onmessage = evt => {
          const payload = JSON.parse(evt.data)
          this._onMessage(payload)
        }
        this._socket.onopen = evt => {
          console.log('OPEN!!!')
        }
    }
  }

  _onMessage ({ action, data }: IncomingApiMessage<keyof IncomingMessagePayload>): void {
    if (!this.EVENTS.has(action)) {
      return this.sendLogs(`Event ${action} is not supported`)
    }

    const evt = new CustomEvent(action, { detail: data })
    this.dispatchEvent(evt)
  }
}
