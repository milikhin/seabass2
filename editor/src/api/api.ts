import { InputPreferences, SeabassSailfishPreferences } from '../app/model'
import { KeyDownOptions } from '../editor/editor'
import {
  API_TRANSPORT,
  FileActionOptions,
  FileLoadOptions
} from './api-interface'

export interface IncomingMessageData {
  closeFile: FileActionOptions
  fileSaved: undefined
  keyDown: KeyDownOptions
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

export interface IncomingMessage<T extends keyof IncomingMessageData> {
  action: T
  data: IncomingMessageData[T]
}

interface OutgoingMessage {
  action: string
  data: unknown
}

interface ApiOptions {
  /** Platform-specific API backend */
  transport: API_TRANSPORT
}

type SeabassApiEvent<T extends keyof IncomingMessageData> = CustomEvent<IncomingMessageData[T]>
type SeabassApiEventListener <T extends keyof IncomingMessageData> = ((evt: SeabassApiEvent<T>) => void) |
({ handleEvent: (evt: SeabassApiEvent<T>) => void }) | null

export default class SeabassApi extends EventTarget {
  /** Platform-specific API backend name */
  _transport: API_TRANSPORT

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
    'undo'
  ])

  constructor ({ transport }: ApiOptions) {
    super()
    this._transport = transport

    window.postSeabassApiMessage = this._onMessage.bind(this)
  }

  _onMessage ({ action, data }: IncomingMessage<keyof IncomingMessageData>): void {
    if (!this.EVENTS.has(action)) {
      return this.sendLogs(`Event ${action} is not supported`)
    }

    const evt = new CustomEvent(action, { detail: data })
    this.dispatchEvent(evt)
  }

  addEventListener<T extends keyof IncomingMessageData> (type: T,
    callback: SeabassApiEventListener<T>, options?: EventListenerOptions): void {
    super.addEventListener(type, callback as EventListenerOrEventListenerObject | null, options)
  }

  sendError (message: string): void {
    this.send({ action: 'error', data: { message } })
  }

  sendLogs = (message: unknown): void => {
    this.send({ action: 'log', data: { message } })
  }

  send ({ action, data }: OutgoingMessage): void {
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
        return window.location.assign(`http://seabass/${encodeURIComponent(payload)}`)
      }
    }
  }
}
