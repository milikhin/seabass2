import SeabassApi from '../api/api'
import {
  API_TRANSPORT,
  FileActionOptions,
  FileLoadOptions
} from '../api/api-interface'
import Tabs from '../tabs/tabs'
import SeabassView from './view'
import SeabassAppModel, {
  EditorStateChangeOptions,
  InputPreferences,
  SeabassSailfishPreferences
} from './model'

import './app.css'

/** App initialization options */
interface SeabassOptions {
  /** Welcome notes elem */
  welcomeElem: HTMLElement
  /** App root elem */
  rootElem: HTMLElement
  /** Platform-specific API transport method */
  apiTransport: API_TRANSPORT
}

/**
 * Main class for the crossplatform HTML5 part of app.
 * Handles API events.
 */
class SeabassApp {
  /** API to interact between platform-specific app and crossplatform editor */
  _api: SeabassApi
  /** app model: preferences and list of opened editors */
  _model: SeabassAppModel
  /** app view */
  _view: SeabassView
  /** opened tabs */
  _tabs: Tabs

  constructor ({ apiTransport, rootElem, welcomeElem }: SeabassOptions) {
    this._api = new SeabassApi({ transport: apiTransport })
    this._model = new SeabassAppModel()
    this._view = new SeabassView({ model: this._model, rootElem, welcomeElem })
    this._tabs = new Tabs({ rootElem })

    this._registerApiEventListeners()
    this._api.send({ action: 'appLoaded', data: this._model.sailfishPreferences })
  }

  /**
   * Registers event listeners for API/model events
   */
  _registerApiEventListeners (): void {
    this._api.addEventListener('closeFile', this._onCloseFile.bind(this))
    this._api.addEventListener('fileSaved', this._forwardEvent.bind(this))
    this._api.addEventListener('keyDown', this._forwardEvent.bind(this))
    this._api.addEventListener('loadFile', this._onLoadFile.bind(this))
    this._api.addEventListener('openFile', this._onOpenFile.bind(this))
    this._api.addEventListener('oskVisibilityChanged', this._forwardEvent.bind(this))
    this._api.addEventListener('redo', this._forwardEvent.bind(this))
    this._api.addEventListener('requestFileSave', this._onRequestFileSave.bind(this))
    this._api.addEventListener('setPreferences', this._onSetPreferences.bind(this))
    this._api.addEventListener('setSailfishPreferences', this._onSetSailfishPreferences.bind(this))
    this._api.addEventListener('toggleReadOnly', this._forwardEvent.bind(this))
    this._api.addEventListener('undo', this._forwardEvent.bind(this))

    this._model.addEventListener('stateChange', this._onStateChange.bind(this))
    this._model.addEventListener('log', this._onLog.bind(this))
  }

  /**
   * Forwards API event to the corresponding Editor
   * @param evt event to forward
   */
  _forwardEvent (evt: CustomEvent): void {
    const tab = this._tabs.currentTab
    if (tab === undefined) {
      return
    }

    this._model.forwardEvent(tab.id, evt)
  }

  /**
   * Loads new file to the editor
   * @param evt loadFile event
   */
  _onLoadFile (evt: CustomEvent<FileLoadOptions>): void {
    const tab = this._tabs.create(evt.detail.filePath)
    this._tabs.show(tab.id)
    this._model.loadFile(evt.detail, tab.elem)
  }

  /**
   * Opens tab with given file
   * @param evt openFile event
   */
  _onOpenFile (evt: CustomEvent<FileActionOptions>): void {
    const tab = this._tabs.create(evt.detail.filePath)
    this._tabs.show(tab.id)
  }

  /**
   * Closes opened file
   * @param evt closeFile event
   */
  _onCloseFile (evt: CustomEvent<FileActionOptions>): void {
    this._tabs.close(evt.detail.filePath)
    this._model.closeFile(evt.detail.filePath)
  }

  /**
   * Requests file saving
   * @param evt requestFileSave event
   */
  _onRequestFileSave (evt: CustomEvent<FileActionOptions>): void {
    const filePath = evt.detail.filePath
    const content = this._model.getContent(filePath)
    this._api.send({
      action: 'saveFile',
      data: { content, filePath }
    })
  }

  /**
   * Loads saved preferences
   * @param evt setTheme event
   */
  _onSetPreferences (evt: CustomEvent<InputPreferences>): void {
    this._model.setPreferences(evt.detail)
  }

  /**
   * Loads saved SailfishOS-specific preferences
   * @param evt setTheme event
   */
  _onSetSailfishPreferences (evt: CustomEvent<SeabassSailfishPreferences>): void {
    this._model.setSailfishPreferences(evt.detail)
  }

  /**
   * Forwards UI state changes to the platform-specific app
   * @param evt state change event
   */
  _onStateChange (evt: CustomEvent<EditorStateChangeOptions>): void {
    this._api.send({ action: 'stateChanged', data: evt.detail })
  }

  /**
   * Sends logs to the platform-specific app
   * @param evt custom event containing data to log
   */
  _onLog (evt: CustomEvent<unknown>): void {
    this._api.sendLogs(evt.detail)
  }
}

/**
 * Initializes app
 * @param options app options
 * @returns app instance
 */
export default function createApp (options: SeabassOptions): SeabassApp {
  return new SeabassApp(options)
}
