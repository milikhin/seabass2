import { EditorState } from '@codemirror/state'
import { undoDepth, redoDepth, undo, redo } from '@codemirror/commands'
import { EditorView, runScopeHandlers } from '@codemirror/view'
import { searchPanelOpen, openSearchPanel, closeSearchPanel } from '@codemirror/search'
import { RawEditorConfig, SetContentOptions } from '../api/api-interface'
import { SeabassCommonPreferences } from '../app/model'
import EditorSetup from './setup'
import { parseEditorConfig } from './utils'

import './editor.css'
import './search-panel.css'

export interface SeabassEditorState {
  hasChanges: boolean
  hasRedo: boolean
  hasUndo: boolean
  isReadOnly: boolean
  searchPanelHeight: number
}

interface EditorOptions {
  content: string
  editorConfig: RawEditorConfig
  elem: HTMLElement
  filePath: string
  isLsEnabled: boolean
  useWrapMode: boolean

  isDarkTheme?: boolean
  isReadOnly?: boolean
  fontSize?: number
  placeSearchOnTop?: boolean
}

interface Events {
  stateChange: CustomEvent<SeabassEditorState>
  log: CustomEvent<unknown>
}
type EventListener <T extends keyof Events> = ((evt: Events[T]) => void) |
({ handleEvent: (evt: Events[T]) => void }) | null

export interface KeyDownOptions {
  keyCode: number
  ctrlKey?: boolean
}

/**
 * Editor window
 */
export default class Editor extends EventTarget {
  _editorElem: HTMLElement
  _editor: EditorView
  _setup: EditorSetup
  _initialState: EditorState
  _isOskVisible: boolean
  _isReadOnly: boolean
  _oskDebounceTimer: NodeJS.Timeout | null = null

  /** Content-change event timeout (ms) */
  ON_CHANGE_TIMEOUT = 250
  SCROLL_INTO_VIEW_TIMEOUT = 250
  OSK_SCROLL_DELAY = 100
  SEARCH_BTN_QUERY = '.editor .cm-editor .cm-panel.cm-search'

  constructor (options: EditorOptions) {
    super()
    // setup extensions
    this._setup = new EditorSetup({
      editorConfig: parseEditorConfig(options.editorConfig),
      isReadOnly: options.isReadOnly ?? false,
      isDarkTheme: options.isDarkTheme ?? false,
      onChange: this._onChange.bind(this),
      useWrapMode: options.useWrapMode,
      placeSearchOnTop: options.placeSearchOnTop
    })

    // listen to SearchPanel events
    const updateListenerExtension = EditorView.updateListener.of(this._onChange.bind(this))

    // set initial editor state
    this._initialState = EditorState.create({
      extensions: [...this._setup.extensions, updateListenerExtension],
      doc: options.content
    })
    this._isOskVisible = false
    this._isReadOnly = options.isReadOnly ?? false

    // init editor
    this._editorElem = options.elem
    this._editorElem.classList.add('editor')
    this._editor = new EditorView({
      state: this._initialState,
      parent: this._editorElem
    })
    void this._initLanguageSupport(options.filePath, options.isLsEnabled)

    // init DOM event handlers (resize, keypress)
    this._initDomEventHandlers()
  }

  addEventListener<T extends keyof Events> (type: T,
    callback: EventListener<T>, options?: EventListenerOptions): void {
    super.addEventListener(type, callback as EventListenerOrEventListenerObject | null, options)
  }

  /**
   * Destroys editor
   */
  destroy (): void {
    this._removeDomEventHandlers()
    this._editor.destroy()
    const editorParentElem = this._editorElem.parentElement as HTMLElement
    editorParentElem.removeChild(this._editorElem)
  }

  dispatchEvent<T extends keyof Events> (event: Events[T]): boolean {
    return super.dispatchEvent(event)
  }

  /**
   * Returns editor content for the given file
   * @returns file content
   */
  getContent (): string {
    // eslint-disable-next-line @typescript-eslint/no-base-to-string
    return this._editor.state.doc.toString()
  }

  /**
   * Generates key down event
   * @param param0 event details
   * @param param0.keyCode - key code
   * @param param0.ctrlKey - 'ctrl key pressed' flag
   */
  keyDown ({ keyCode, ctrlKey }: KeyDownOptions): void {
    const evt = new KeyboardEvent('', { keyCode, ctrlKey })
    runScopeHandlers(this._editor, evt, 'editor')
  }

  /**
   * Handles 'file has been saved' event
   */
  fileSaved (): void {
    this._initialState = this._editor.state
    this._onChange()
  }

  setContent (options: SetContentOptions): void {
    this._editor.dispatch({
      changes: options.append === false
        ? {
            from: 0,
            to: this._editor.state.doc.length,
            insert: options.content
          }
        : {
            from: this._editor.state.doc.length,
            insert: options.content
          }
    })
    const lastLine = this._editor.state.doc.length
    this._editor.dispatch({
      effects: EditorView.scrollIntoView(lastLine)
    })
  }

  /**
   * Set editor preferences
   * @param param0 editor preferences
   */
  setPreferences (options: SeabassCommonPreferences): void {
    const theme = this._setup.getThemeConfig({
      isDarkTheme: options.isDarkTheme
    })
    const lineWrapping = this._setup.getLineWrappingConfig(options.useWrapMode ?? true)

    this._editor.dispatch({
      effects: [
        this._setup.lineWrappingCompartment.reconfigure(lineWrapping),
        this._setup.themeCompartment.reconfigure(theme)
      ]
    })
  }

  /**
   * Redo next change from editor history
   */
  redo (): void {
    redo({ state: this._editor.state, dispatch: this._editor.dispatch })
  }

  /**
   * Undo last change from editor history
   */
  undo (): void {
    undo({ state: this._editor.state, dispatch: this._editor.dispatch })
  }

  /**
   * Handles on-screen keyboard visibility change event
   * @param param0 OSK state
   */
  oskVisibilityChanged ({ isVisible }: { isVisible: boolean }): void {
    this._isOskVisible = isVisible

    if (this._isOskVisible) {
      // scroll into view when opening virtual keyboard
      setTimeout(() => this._editor.dispatch({
        effects: EditorView.scrollIntoView(this._editor.state.selection.ranges[0])
      }), this.SCROLL_INTO_VIEW_TIMEOUT)
    }
  }

  /**
   * Toggles readonly mode
   */
  toggleReadOnly (): void {
    this._isReadOnly = !this._isReadOnly
    this._editor.dispatch({
      effects: this._setup.readOnlyCompartment.reconfigure(
        EditorView.editable.of(!this._isReadOnly))
    })
    this._onChange()
  }

  toggleSearchPanel (): void {
    const isOpened = searchPanelOpen(this._editor.state)
    if (isOpened) {
      closeSearchPanel(this._editor)
    } else {
      openSearchPanel(this._editor)
    }
  }

  /**
   * Returns editor state required to render app UI
   * @returns editor state
   */
  getUiState (): SeabassEditorState {
    const isSearchPanelOpened = searchPanelOpen(this._editor.state)
    const searchPanelHeight = isSearchPanelOpened
      ? document.querySelector(this.SEARCH_BTN_QUERY)?.clientHeight ?? 0
      : 0
    return {
      hasChanges: !this._isReadOnly && !this._editor.state.doc.eq(this._initialState.doc),
      hasUndo: !this._isReadOnly && undoDepth(this._editor.state) > 0,
      hasRedo: !this._isReadOnly && redoDepth(this._editor.state) > 0,
      isReadOnly: this._isReadOnly,
      searchPanelHeight: searchPanelHeight * window.devicePixelRatio
    }
  }

  /** Called when editor becomes visible */
  openFile (): void {
    this._onChange()
  }

  /** Handles viewport resizing */
  resize = (): void => {}

  async _initLanguageSupport (filePath: string, isLsEnabled: boolean): Promise<void> {
    const effects = await this._setup.setupLanguageSupport(filePath, isLsEnabled)
    this._editor.dispatch({ effects })
  }

  _initDomEventHandlers (): void {
    this._editorElem.addEventListener('keypress', this._onKeyPress, true)
    ;(this._editorElem.querySelector('.cm-scroller') as HTMLElement)
      .addEventListener('scroll', this._tmpDisableScrollIntoView)
    window.addEventListener('resize', this.resize)
  }

  _onChange (): void {
    this.dispatchEvent(new CustomEvent('stateChange', {
      detail: this.getUiState()
    }))
  }

  _onKeyPress = (evt: KeyboardEvent): void => {
    /* `Enter`, `Backspace` and Arrows are handled twice on SfOS, disable redundant keypress handler */
    const duplicatedKeyCodes = [8, 13, 37, 38, 39, 40]
    if (duplicatedKeyCodes.includes(evt.keyCode)) {
      evt.preventDefault()
    }
  }

  _tmpDisableScrollIntoView = (): void => {
    if (this._isReadOnly || this._isOskVisible) {
      return
    }

    if (this._oskDebounceTimer === null) {
      this._editor.dispatch({
        effects: this._setup.readOnlyCompartment.reconfigure(
          EditorView.editable.of(false))
      })
    } else {
      clearTimeout(this._oskDebounceTimer)
    }

    this._oskDebounceTimer = setTimeout(() => {
      this._editor.dispatch({
        effects: this._setup.readOnlyCompartment.reconfigure(
          EditorView.editable.of(true))
      })
      this._oskDebounceTimer = null
    }, this.OSK_SCROLL_DELAY)
  }

  _removeDomEventHandlers (): void {
    this._editorElem.removeEventListener('keypress', this._onKeyPress, true)
    ;(this._editorElem.querySelector('.cm-scroller') as HTMLElement)
      .removeEventListener('scroll', this._tmpDisableScrollIntoView)
    window.removeEventListener('resize', this.resize)
  }
}
