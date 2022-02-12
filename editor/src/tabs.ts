export interface Tab {
  elem: HTMLElement
  id: string
  isVisible: boolean
  onClose: (tab: Tab) => void
  onHide: (tab: Tab) => void
  onShow: (tab: Tab) => void
}

export interface CreateTabOptions {
  id: string
  onClose?: (tab: Tab) => void
  onHide?: (tab: Tab) => void
  onShow?: (tab: Tab) => void
}

export interface TabsOptions {
  rootElem: HTMLElement
}

const emptyCallback = (): void => { /* noop */ }

export default class TabsModel {
  _currentTabId?: string
  _rootElem: HTMLElement
  _tabs: Map<string, Tab>

  constructor ({ rootElem }: TabsOptions) {
    this._tabs = new Map()
    this._rootElem = rootElem
  }

  get list (): Tab[] {
    return Array.from(this._tabs.values())
  }

  get currentTab (): Tab|undefined {
    if (this._currentTabId === undefined || !this._tabs.has(this._currentTabId)) {
      return
    }

    return this._tabs.get(this._currentTabId) as Tab
  }

  get currentTabId (): string|undefined {
    return this._currentTabId
  }

  create (options: CreateTabOptions): Tab {
    const contentElem = document.createElement('div')
    this._rootElem.appendChild(contentElem)
    contentElem.classList.add('tab')

    const tab: Tab = {
      id: options.id,
      isVisible: false,
      elem: contentElem,
      onClose: options.onClose ?? emptyCallback,
      onHide: options.onHide ?? emptyCallback,
      onShow: options.onShow ?? emptyCallback
    }

    this._tabs.set(options.id, tab)
    this.show(options.id)
    return tab
  }

  close (id: string): void {
    const tab = this._tabs.get(id)
    if (tab === undefined) {
      return
    }

    tab.onClose(tab)
    tab.elem.parentElement?.removeChild(tab.elem)
    this._tabs.delete(id)
    if (this._currentTabId === id) {
      this._currentTabId = undefined
    }
  }

  show (id: string): void {
    const previousTab = this._currentTabId !== undefined && this._tabs.has(id)
      ? this._tabs.get(id) as Tab
      : undefined
    if (previousTab !== undefined) {
      previousTab.elem.style.display = 'none'
      previousTab.onHide(previousTab)
    }

    const newActiveTab = this._tabs.get(id)
    if (newActiveTab !== undefined) {
      newActiveTab.elem.style.display = ''
      newActiveTab.onShow(newActiveTab)
    }
  }
}
