import md5 from 'blueimp-md5'
import { EditorState, EditorView } from '@codemirror/basic-setup'
import { oneDark } from '@codemirror/theme-one-dark'
import { undoDepth, redoDepth, undo, redo } from '@codemirror/commands'
import { runScopeHandlers } from '@codemirror/view'
import { RawEditorConfig, SeabassEditorPreferences } from '../types'
import EditorSetup from './setup'
import { SeabassEditorConfig, SeabassEditorState } from './types'
import { parseEditorConfig } from './utils'

import './editor.css'

interface EditorOptions {
  content: string
  editorConfig: RawEditorConfig
  elem: HTMLElement
  filePath: string
  isDarkTheme?: boolean
  isReadOnly?: boolean
  isTerminal?: boolean
  log: (message: unknown) => void
  onChange: (state: SeabassEditorState) => void
}

interface KeyDownOptions {
  keyCode: number
  ctrlKey?: boolean
}

/**
 * Editor window
 */
export default class Editor {
  _editorElem: HTMLElement
  _editorConfig: SeabassEditorConfig
  _isTerminal: boolean
  _editor: EditorView
  _editorSetup: EditorSetup
  _savedContentHash?: string
  _isOskVisible: boolean
  _isReadOnly: boolean
  _log: (message: unknown) => void
  _onStateChange: (content?: string) => void

  /** Content-change event timeout (ms) */
  ON_CHANGE_TIMEOUT = 250

  constructor (options: EditorOptions) {
    this._log = options.log
    this._onStateChange = this._getStateChangeHandler(options)
    this._editorSetup = new EditorSetup({
      isReadOnly: options.isReadOnly ?? false,
      isDarkTheme: options.isDarkTheme ?? false,
      onStateChange: this._onStateChange
    })

    // set initial editor state
    this._editorConfig = parseEditorConfig(options.editorConfig)
    this._isOskVisible = false
    this._isTerminal = options.isTerminal ?? false
    this._isReadOnly = options.isReadOnly ?? false

    // init editor
    this._editorElem = options.elem
    this._editorElem.classList.add('editor')
    this._editor = new EditorView({
      state: EditorState.create({
        extensions: this._editorSetup.extensions,
        doc: options.content
      }),
      parent: this._editorElem
    })
    this._savedContentHash = md5(this.getContent())
    this._onStateChange()
    void this._initLanguageSupport(options.filePath)

    // init DOM event handlers (resize, keypress)
    this._initDomEventHandlers()
  }

  /**
   * Destroys editor
   */
  destroy (): void {
    const editorParentElem = this._editorElem.parentElement as HTMLElement
    editorParentElem.removeChild(this._editorElem)
    this._removeDomEventHandlers()
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

  fileSaved ({ content }: { content: string }): void {
    this._savedContentHash = md5(content)
    this._onStateChange()
  }

  setPreferences ({ isDarkTheme }: SeabassEditorPreferences): void {
    this._editor.dispatch({
      effects: this._editorSetup.themeCompartment.reconfigure(isDarkTheme
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
    this._isReadOnly = !this._isReadOnly
    this._editor.dispatch({
      effects: this._editorSetup.readOnlyCompartment.reconfigure(
        EditorView.editable.of(!this._isReadOnly))
    })
    this._onStateChange()
  }

  _getStateChangeHandler (options: EditorOptions): (content?: string) => void {
    return (content?: string) => {
      const text = content ?? this.getContent()
      options.onChange({
        filePath: options.filePath,
        hasChanges: this._savedContentHash !== md5(text),
        hasUndo: undoDepth(this._editor.state) > 0,
        hasRedo: redoDepth(this._editor.state) > 0,
        isReadOnly: this._isReadOnly
      })
    }
  }

  async _initLanguageSupport (filePath: string): Promise<void> {
    const effects = await this._editorSetup.setupLanguageSupport(filePath)
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
    this._onStateChange()
  }

  _removeDomEventHandlers (): void {
    window.removeEventListener('resize', this._onResize)
  }
}
