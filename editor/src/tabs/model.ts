export interface Tab {
  elem: HTMLElement
  id: string
}

type TabEventName = 'create'|'close'|'show'
class TabEvent extends CustomEvent<Tab> {
  constructor (type: TabEventName, tab: Tab) {
    super(type, { detail: tab })
  }
}
type TabEventListener = ((evt: TabEvent) => void) | ({ handleEvent: (evt: TabEvent) => void }) | null
type EventListenerOptions = boolean | AddEventListenerOptions

export default class TabsModel extends EventTarget {
  /** currenty active tab's ID */
  _currentTabId?: string
  /** existing tabs */
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

  /**
   * Creates new tab with given ID
   * @param id unique tab id
   * @returns created tab
   */
  create (id: string): Tab {
    const tab = { id, elem: document.createElement('div') }
    this._tabs.set(id, tab)
    this.dispatchEvent(new TabEvent('create', tab))
    return tab
  }

  /**
   * Closes tab with given ID
   * @param id unique tab id
   */
  close (id: string): void {
    const tab = this._tabs.get(id)
    if (tab === undefined) {
      return
    }
    this._tabs.delete(id)
    if (this._currentTabId === id) {
      this._currentTabId = undefined
    }
    this.dispatchEvent(new TabEvent('close', tab))
  }

  /**
   * Returns tab by ID
   * @param id unique tab id
   * @returns tab
   */
  get (id: string): Tab|undefined {
    return this._tabs.get(id)
  }

  /**
   * Activates tab with given ID
   * @param id unique tab id
   */
  show (id: string): void {
    if (!this._tabs.has(id)) {
      return
    }

    this._currentTabId = id
    const currentTab = this._tabs.get(this._currentTabId) as Tab
    this.dispatchEvent(new TabEvent('show', currentTab))
  }
}
