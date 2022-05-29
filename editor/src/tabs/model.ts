export interface Tab {
  elem: HTMLElement
  id: string
}

type TabEventName = 'create'|'close'|'show'|'hide'
class TabEvent extends CustomEvent<Tab> {
  constructor (type: TabEventName, tab: Tab) {
    super(type, { detail: tab })
  }
}
type TabEventListener = ((evt: TabEvent) => void) | ({ handleEvent: (evt: TabEvent) => void }) | null
type EventListenerOptions = boolean | AddEventListenerOptions

export default class TabsModel extends EventTarget {
  _currentTabId?: string
  _tabs: Map<string, Tab>

  constructor () {
    super()
    this._tabs = new Map()
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

  addEventListener (type: TabEventName, callback: TabEventListener, options?: EventListenerOptions): void {
    super.addEventListener(type, callback as EventListenerOrEventListenerObject | null, options)
  }

  dispatchEvent (event: TabEvent): boolean {
    return super.dispatchEvent(event)
  }

  create (id: string): Tab {
    const tab = { id, elem: document.createElement('div') }
    this._tabs.set(id, tab)
    this.dispatchEvent(new TabEvent('create', tab))
    return tab
  }

  close (id: string): void {
    const tab = this._tabs.get(id)
    this._tabs.delete(id)

    if (tab !== undefined) {
      this.dispatchEvent(new TabEvent('close', tab))
    }
  }

  get (id: string): Tab|undefined {
    return this._tabs.get(id)
  }

  show (id: string): void {
    if (!this._tabs.has(id)) {
      return
    }

    const prevTabId = this._currentTabId
    if (prevTabId !== undefined && this._tabs.has(prevTabId)) {
      const prevTab = this._tabs.get(prevTabId) as Tab
      this.dispatchEvent(new TabEvent('hide', prevTab))
    }

    this._currentTabId = id
    const currentTab = this._tabs.get(this._currentTabId) as Tab
    this.dispatchEvent(new TabEvent('show', currentTab))
  }
}
