import md5 from 'blueimp-md5'
import { EditorState, EditorView, basicSetup } from '@codemirror/basic-setup'
import { html } from '@codemirror/lang-html'
import { oneDark } from '@codemirror/theme-one-dark'
import { indentWithTab } from '@codemirror/commands'
import { undoDepth, redoDepth, undo, redo } from '@codemirror/history'
import { keymap, runScopeHandlers } from '@codemirror/view'
import { SeabassEditorConfig, SeabassEditorState } from '../types'
import { Compartment, Extension } from '@codemirror/state'
import { getLanguageMode } from './language'

import './editor.css'

interface EditorOptions {
  content: string
  editorConfig: SeabassEditorConfig
  elem: HTMLElement
  filePath: string
  isReadOnly?: boolean
  isTerminal?: boolean
  onChange: (state: SeabassEditorState) => void
}

interface KeyDownOptions {
  keyCode: number
}

/**
 * Editor window
 */
export default class Editor {
  _editorElem: HTMLElement
  _editorConfig: SeabassEditorConfig
  _isTerminal: boolean
  _editor: EditorView
  _savedContentHash?: string
  _isReadOnly: boolean
  _langCompartment: Compartment
  _readOnlyCompartment: Compartment

  /** Content-change event timeout (ms) */
  ON_CHANGE_TIMEOUT = 250

  constructor (options: EditorOptions) {
    this._editorElem = options.elem
    this._editorConfig = options.editorConfig
    this._isTerminal = options.isTerminal ?? false
    this._readOnlyCompartment = new Compartment()
    this._langCompartment = new Compartment()
    this._editor = new EditorView({
      state: EditorState.create({
        extensions: this._getExtensions(options),
        doc: options.content
      }),
      parent: this._editorElem
    })

    this._savedContentHash = undefined
    this._isReadOnly = options.isReadOnly ?? false
    this._editorElem.classList.add('editor')

    void this._initLanguageSupport(options.filePath)
    // window.addEventListener('resize', this._onResize)
  }

  destroy (): void {
    (this._editorElem.parentElement as HTMLElement).removeChild(this._editorElem)
    // window.removeEventListener('resize', this._onResize)
  }

  /**
   * Returns editor content for the given file
   * @returns {string|undefined} - file content
   */
  getContent (state: EditorState = this._editor.state): string {
    const lines = state.doc.toJSON()
    if (lines[lines.length - 1] !== '') {
      lines.push('')
    }

    return lines.join('\r\n')
  }

  keyDown ({ keyCode }: KeyDownOptions): void {
    const evt = new KeyboardEvent('', { keyCode })
    runScopeHandlers(this._editor, evt, 'editor')
  }

  setSavedContent (content: string): void {
    this._savedContentHash = md5(content)
    // this._onChange()
  }

  setPreferences ({ fontSize, isDarkTheme, useWrapMode }): void {

  }

  redo (): void {
    redo({ state: this._editor.state, dispatch: this._editor.dispatch })
  }

  undo (): void {
    undo({ state: this._editor.state, dispatch: this._editor.dispatch })
  }

  toggleReadOnly (): void {
    this._isReadOnly = !this._isReadOnly
    this._editor.dispatch({
      effects: this._readOnlyCompartment.reconfigure(EditorView.editable.of(!this._isReadOnly))
    })
  }

  _getExtensions (options: EditorOptions): Extension[] {
    const isReadOnly = options.isReadOnly ?? false
    const extensions: Extension[] = [
      basicSetup,
      keymap.of([indentWithTab]),
      oneDark,
      this._readOnlyCompartment.of(EditorView.editable.of(!isReadOnly)),
      this._langCompartment.of(html()),
      EditorView.updateListener.of(update => {
        if (!update.docChanged) {
          return
        }

        const text = this.getContent(update.state)
        options.onChange({
          filePath: options.filePath,
          hasChanges: this._savedContentHash !== md5(text),
          hasUndo: undoDepth(this._editor.state) > 0,
          hasRedo: redoDepth(this._editor.state) > 0,
          isReadOnly: this._isReadOnly,
          selectedText: ''
        })
      })
    ]

    return extensions
  }

  async _initLanguageSupport (filePath: string): Promise<void> {
    const langSupport = await getLanguageMode(filePath)
    if (langSupport === undefined) {
      return
    }

    this._editor.dispatch({
      effects: this._langCompartment.reconfigure(langSupport)
    })
  }
}
