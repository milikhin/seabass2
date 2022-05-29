import TabsModel, { Tab } from './model'
import TabsView from './view'

export interface TabOptions {
  id: string
}

export interface TabsOptions {
  rootElem: HTMLElement
}

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

  create (id: string): Tab {
    return this._model.create(id)
  }

  close (id: string): void {
    return this._model.close(id)
  }

  show (id: string): void {
    return this._model.show(id)
  }
}
