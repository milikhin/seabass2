import TabsModel, { Tab } from './model'

interface TabsViewOptions {
  model: TabsModel
  rootElem: HTMLElement
}

/**
 * Tabs view.
 * Displays currently active tab of a used model
 */
export default class TabsView {
  _model: TabsModel
  _rootElem: HTMLElement
  _contentElems: Map<string, HTMLDivElement>

  constructor ({ model, rootElem }: TabsViewOptions) {
    this._model = model
    this._rootElem = rootElem
    this._registerEventHandlers()
    this._contentElems = new Map()
  }

  _registerEventHandlers (): void {
    this._model.addEventListener('create', evt => {
      this._onCreate(evt.detail)
    })
    this._model.addEventListener('close', evt => {
      this._onClose(evt.detail)
    })
    this._model.addEventListener('hide', evt => {
      this._onHide(evt.detail)
    })
    this._model.addEventListener('show', evt => {
      this._onShow(evt.detail)
    })
  }

  _onCreate ({ id, elem }: Tab): HTMLDivElement {
    const contentElem = document.createElement('div')
    contentElem.classList.add('tab')
    contentElem.appendChild(elem)
    this._rootElem.appendChild(contentElem)
    this._contentElems.set(id, contentElem)
    return contentElem
  }

  _onClose ({ id }: Tab): void {
    const contentElem = this._contentElems.get(id)
    if (contentElem === undefined) {
      return
    }

    contentElem.parentElement?.removeChild(contentElem)
    this._contentElems.delete(id)
  }

  _onHide ({ id }: Tab): void {
    const contentElem = this._contentElems.get(id)
    if (contentElem === undefined) {
      return
    }

    contentElem.style.display = 'none'
  }

  _onShow ({ id }: Tab): void {
    const contentElem = this._contentElems.get(id)
    if (contentElem === undefined) {
      return
    }

    contentElem.style.display = ''
  }
}
