import { EditorView, EditorState, basicSetup } from '@codemirror/basic-setup'
import { Compartment, Extension, Facet, StateEffect } from '@codemirror/state'
import { keymap } from '@codemirror/view'
import { indentWithTab } from '@codemirror/commands'
import { oneDark } from '@codemirror/theme-one-dark'
import { getLanguageMode } from './language'

interface ExtensionsOptions {
  isReadOnly?: boolean
  isDarkTheme?: boolean

  onStateChange: (content?: string) => void
}

export default class EditorSetup {
  readOnlyCompartment: Compartment
  langCompartment: Compartment
  themeCompartment: Compartment
  extensions: Extension[]

  constructor (options: ExtensionsOptions) {
    this.readOnlyCompartment = new Compartment()
    this.langCompartment = new Compartment()
    this.themeCompartment = new Compartment()

    this.extensions = [
      basicSetup,
      keymap.of([indentWithTab]),
      this._getDefaultLangExtension(options),
      this._getDocChangeHandlerExtension(options),
      this._getDomEventHandlerExtension(options),
      this._getReadOnlyExtension(options),
      this._getThemeExtension(options)
    ]
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

      const text = this._getContent(update.state)
      options.onStateChange(text)
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

        options.onStateChange()
      }
    })
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

  async setupLanguageSupport (filePath: string): Promise<StateEffect<unknown>> {
    const langSupport = await getLanguageMode(filePath)
    return this.langCompartment.reconfigure(langSupport ?? Facet.define().of(null))
  }
}
