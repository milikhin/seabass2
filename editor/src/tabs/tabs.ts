import TabsModel, { Tab } from './model'
import TabsView from './view'

export interface TabOptions {
  id: string
}

export interface TabsOptions {
  rootElem: HTMLElement
}

/**
 * Tabs content. Controls should be implemented within the platform-specific part of the app.
 * There could be multiple tabs. Only one of them is visible at a time
 */
export default class Tabs {
  _model: TabsModel
  _view: TabsView

  addEventListener: TabsModel['addEventListener']

  constructor ({ rootElem }: TabsOptions) {
    this._model = new TabsModel()
    this._view = new TabsView({
      rootElem,
      model: this._model
    })
    this.addEventListener = this._model.addEventListener.bind(this._model)
  }

  get currentTab (): Tab|undefined {
    return this._model.currentTab
  }

  /**
   * Creates new tab
   * @param id unique tab ID
   * @returns tab
   */
  create (id: string): Tab {
    return this._model.create(id)
  }

  /**
   * Coses tab with given ID
   * @param id unique tab ID
   */
  close (id: string): void {
    this._model.close(id)
  }

  /**
   * Shows tab with given ID, hides currently active tab
   * @param id unique tab ID
   */
  show (id: string): void {
    this._model.show(id)
  }

  get (id: string): Tab|undefined {
    return this._model.get(id)
  }
}
