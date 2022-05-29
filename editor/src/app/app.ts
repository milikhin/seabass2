import Tabs from '../tabs/tabs'
import { SeabassOptions } from './types'
import SeabassView from './view'
import SeabassAppModel, { InputPreferences, SeabassSailfishPreferences } from './model'
import SeabassApi from '../api/api'
import { FileActionOptions, FileLoadOptions } from '../api/api-interface'
import { SeabassEditorState } from '../editor/types'

import './app.css'

class SeabassApp {
  _api: SeabassApi
  _model: SeabassAppModel
  _view: SeabassView
  _tabs: Tabs

  constructor ({ apiBackend, rootElem, welcomeElem }: SeabassOptions) {
    this._api = new SeabassApi({ transport: apiBackend })
    this._model = new SeabassAppModel()
    this._view = new SeabassView({ model: this._model, rootElem, welcomeElem })
    this._tabs = new Tabs({ rootElem })

    this._registerApiEventListeners()
    this._api.send({ action: 'appLoaded', data: this._model.sailfishPreferences })
  }

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
  }

  _forwardEvent (evt: CustomEvent): void {
    const tab = this._tabs.currentTab
    if (tab === undefined) {
      return
    }

    this._model.forwardEvent(tab.id, evt)
  }

  /**
   * Loads given content to the editor
   * @param {CustomEvent<FileLoadOptions>} evt loadFile event
   * @returns {undefined}
   */
  _onLoadFile (evt: CustomEvent<FileLoadOptions>): void {
    const tab = this._tabs.create(evt.detail.filePath)
    this._tabs.show(tab.id)
    this._model.loadFile(evt.detail, tab.elem)
  }

  /**
   * Opens tab with given file
   * @param {CustomEvent<FileActionOptions>} evt openFile event
   * @returns {undefined}
   */
  _onOpenFile (evt: CustomEvent<FileActionOptions>): void {
    const tab = this._tabs.create(evt.detail.filePath)
    this._tabs.show(tab.id)
  }

  /**
   * Closes opened file
   * @param {CustomEvent<FileActionOptions>} evt closeFile event
   * @returns {undefined}
   */
  _onCloseFile (evt: CustomEvent<FileActionOptions>): void {
    this._tabs.close(evt.detail.filePath)
    this._model.closeFile(evt.detail.filePath)
  }

  /**
   * Requests file saving
   * @param {CustomEvent<FileActionOptions>} evt requestFileSave event
   * @returns {undefined}
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
   * @param {CustomEvent<InputPreferences>} evt setTheme event
   * @returns {undefined}
   */
  _onSetPreferences (evt: CustomEvent<InputPreferences>): void {
    this._model.setPreferences(evt.detail)
  }

  /**
   * Loads saved SailfishOS-specific preferences
   * @param {CustomEvent<InputPreferences>} evt setTheme event
   * @returns {undefined}
   */
  _onSetSailfishPreferences (evt: CustomEvent<SeabassSailfishPreferences>): void {
    this._model.setSailfishPreferences(evt.detail)
  }

  _onStateChange (evt: CustomEvent<SeabassEditorState>): void {
    this._api.send({ action: 'stateChanged', data: evt.detail })
  }
}

export default function createApp (options: SeabassOptions): SeabassApp {
  return new SeabassApp(options)
}
