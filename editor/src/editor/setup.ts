import { EditorView, basicSetup } from 'codemirror'
import { indentUnit } from '@codemirror/language'
import { Compartment, EditorState, Extension, Facet, StateEffect } from '@codemirror/state'
import { keymap } from '@codemirror/view'
import { history, historyKeymap, indentWithTab } from '@codemirror/commands'
import { oneDark } from '@codemirror/theme-one-dark'
import { getLanguageMode } from './language'
import { SeabassEditorConfig } from './utils'

interface ExtensionsOptions {
  editorConfig: SeabassEditorConfig
  isReadOnly?: boolean
  isDarkTheme?: boolean

  onChange: (content?: string) => void
}

/**
 * Codemirror's setup
 */
export default class EditorSetup {
  /** extension to manage readonly state */
  readOnlyCompartment: Compartment
  /** extension to manage language support */
  langCompartment: Compartment
  /** extension to manage theme */
  themeCompartment: Compartment
  /** list of enabled extensions */
  extensions: Extension[]

  constructor (options: ExtensionsOptions) {
    this.readOnlyCompartment = new Compartment()
    this.langCompartment = new Compartment()
    this.themeCompartment = new Compartment()

    this.extensions = [
      basicSetup,
      history(),
      keymap.of([indentWithTab, ...historyKeymap]),
      this._getDefaultLangExtension(options),
      this._getDocChangeHandlerExtension(options),
      this._getDomEventHandlerExtension(options),
      this._getReadOnlyExtension(options),
      this._getThemeExtension(options),
      indentUnit.of(this._getIndentationString(options.editorConfig)),
      EditorState.tabSize.of(options.editorConfig.tabWidth)
    ]
  }

  /**
   * Init language support for a given file
   * @param filePath full path to file
   * @returns language support extension
   */
  async setupLanguageSupport (filePath: string): Promise<StateEffect<unknown>> {
    const langSupport = await getLanguageMode(filePath)
    return this.langCompartment.reconfigure(langSupport ?? Facet.define().of(null))
  }

  _getContent (state: EditorState): string {
    const lines = state.doc.toJSON()
    if (lines[lines.length - 1] !== '') {
      lines.push('')
    }

    return lines.join('\r\n')
  }

  _getDocChangeHandlerExtension (options: ExtensionsOptions): Extension {
    return EditorView.updateListener.of(update => {
      if (!update.docChanged) {
        return
      }

      options.onChange()
    })
  }

  _getDomEventHandlerExtension (options: ExtensionsOptions): Extension {
    return EditorView.domEventHandlers({
      scroll: evt => {
        if (evt.target === null || !('classList' in evt.target)) {
          return
        }

        const target = evt.target as HTMLElement
        if (!target.classList.contains('cm-scroller')) {
          return
        }

        options.onChange()
      }
    })
  }

  _getIndentationString (editorConfig: SeabassEditorConfig): string {
    switch (editorConfig.indentStyle) {
      case 'tab':
        return '\u0009'
      case 'space':
      default:
        return ' '.repeat(editorConfig.indentSize)
    }
  }

  _getDefaultLangExtension (options: ExtensionsOptions): Extension {
    return this.langCompartment.of(Facet.define().of(null))
  }

  _getReadOnlyExtension (options: ExtensionsOptions): Extension {
    const isReadOnly = options.isReadOnly ?? false
    return this.readOnlyCompartment.of(EditorView.editable.of(!isReadOnly))
  }

  _getThemeExtension (options: ExtensionsOptions): Extension {
    return this.themeCompartment.of(options.isDarkTheme === true
      ? oneDark
      : EditorView.baseTheme({}))
  }
}
