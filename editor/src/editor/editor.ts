import { EditorState, EditorView } from '@codemirror/basic-setup'
import { oneDark } from '@codemirror/theme-one-dark'
import { undoDepth, redoDepth, undo, redo } from '@codemirror/commands'
import { runScopeHandlers } from '@codemirror/view'
import { RawEditorConfig } from '../api/api-interface'
import { SeabassCommonPreferences } from '../app/model'
import EditorSetup from './setup'
import { SeabassEditorConfig } from './types'
import { parseEditorConfig } from './utils'

import './editor.css'

export interface SeabassEditorState {
  hasChanges: boolean
  hasRedo: boolean
  hasUndo: boolean
  isReadOnly: boolean
}

interface EditorOptions {
  content: string
  editorConfig: RawEditorConfig
  elem: HTMLElement
  filePath: string
  isDarkTheme?: boolean
  isReadOnly?: boolean
}

interface Events {
  stateChange: CustomEvent<SeabassEditorState>
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
  _editorConfig: SeabassEditorConfig
  _editor: EditorView
  _setup: EditorSetup
  _initialState: EditorState
  _isOskVisible: boolean

  /** Content-change event timeout (ms) */
  ON_CHANGE_TIMEOUT = 250

  constructor (options: EditorOptions) {
    super()
    // setup extensions
    this._setup = new EditorSetup({
      isReadOnly: options.isReadOnly ?? false,
      isDarkTheme: options.isDarkTheme ?? false,
      onChange: this._onChange.bind(this)
    })

    // set initial editor state
    this._editorConfig = parseEditorConfig(options.editorConfig)
    this._initialState = EditorState.create({
      extensions: this._setup.extensions,
      doc: options.content
    })
    this._isOskVisible = false

    // init editor
    this._editorElem = options.elem
    this._editorElem.classList.add('editor')
    this._editor = new EditorView({
      state: this._initialState,
      parent: this._editorElem
    })
    this._onChange()
    void this._initLanguageSupport(options.filePath)

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
    const editorParentElem = this._editorElem.parentElement as HTMLElement
    editorParentElem.removeChild(this._editorElem)
    this._removeDomEventHandlers()
  }

  dispatchEvent<T extends keyof Events> (event: Events[T]): boolean {
    return super.dispatchEvent(event)
  }

  /**
   * Returns editor content for the given file
   * @returns {string|undefined} - file content
   */
  getContent (): string {
    const lines = this._editor.state.doc.toJSON()
    if (lines[lines.length - 1] !== '') {
      lines.push('')
    }

    return lines.join('\r\n')
  }

  /**
   * Generates key down event
   * @param {number} param0.keyCode - key code
   */
  keyDown ({ keyCode, ctrlKey }: KeyDownOptions): void {
    const evt = new KeyboardEvent('', { keyCode, ctrlKey })
    runScopeHandlers(this._editor, evt, 'editor')
  }

  fileSaved (): void {
    this._initialState = this._editor.state
    this._onChange()
  }

  setPreferences ({ isDarkTheme }: SeabassCommonPreferences): void {
    this._editor.dispatch({
      effects: this._setup.themeCompartment.reconfigure(isDarkTheme
        ? oneDark
        : EditorView.baseTheme({}))
    })
  }

  redo (): void {
    redo({ state: this._editor.state, dispatch: this._editor.dispatch })
  }

  undo (): void {
    undo({ state: this._editor.state, dispatch: this._editor.dispatch })
  }

  oskVisibilityChanged ({ isVisible }: { isVisible: boolean }): void {
    this._isOskVisible = isVisible
  }

  toggleReadOnly (): void {
    const isReadOnly = this._editor.state.readOnly
    this._editor.dispatch({
      effects: this._setup.readOnlyCompartment.reconfigure(
        EditorView.editable.of(!isReadOnly))
    })
    this._onChange()
  }

  _onChange (): void {
    this.dispatchEvent(new CustomEvent('stateChange', {
      detail: {
        hasChanges: !this._editor.state.doc.eq(this._initialState.doc),
        hasUndo: undoDepth(this._editor.state) > 0,
        hasRedo: redoDepth(this._editor.state) > 0,
        isReadOnly: this._editor.state.readOnly
      }
    }))
  }

  async _initLanguageSupport (filePath: string): Promise<void> {
    const effects = await this._setup.setupLanguageSupport(filePath)
    this._editor.dispatch({ effects })
  }

  _initDomEventHandlers (): void {
    this._editorElem.addEventListener('keypress', evt => {
      /* `Enter` and `Backspace` are handled twice on SfOS, disable redundant keypress handler */
      if (evt.keyCode === 8 || evt.keyCode === 13) {
        evt.preventDefault()
      }
    }, true)
    window.addEventListener('resize', this._onResize)
  }

  _onResize = (): void => {
    if (this._isOskVisible) {
      this._editor.dispatch({
        effects: EditorView.scrollIntoView(this._editor.state.selection.ranges[0])
      })
    }
  }

  _removeDomEventHandlers (): void {
    window.removeEventListener('resize', this._onResize)
  }
}
