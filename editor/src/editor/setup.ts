import { EditorView, basicSetup } from 'codemirror'
import { indentUnit } from '@codemirror/language'
import { Compartment, EditorState, Extension, Facet, StateEffect } from '@codemirror/state'
import { keymap } from '@codemirror/view'
import { history, historyKeymap, indentWithTab } from '@codemirror/commands'
import { oneDark } from '@codemirror/theme-one-dark'
import { search, searchKeymap } from '@codemirror/search'
import { getLanguageMode } from './language'
import { SeabassEditorConfig } from './utils'

interface ThemeOptions {
  isDarkTheme?: boolean
}

interface ExtensionsOptions extends ThemeOptions{
  editorConfig: SeabassEditorConfig
  useWrapMode: boolean
  isReadOnly?: boolean
  placeSearchOnTop?: boolean

  onChange: (content?: string) => void
}

/**
 * Codemirror's setup
 */
export default class EditorSetup {
  /** extension to manage line wrapping */
  lineWrappingCompartment: Compartment
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
    this.lineWrappingCompartment = new Compartment()

    this.extensions = [
      basicSetup,
      search({ top: options.placeSearchOnTop }),
      history(),
      keymap.of([indentWithTab, ...historyKeymap, ...searchKeymap]),
      this._getDefaultLangExtension(options),
      this._getDocChangeHandlerExtension(options),
      this._getReadOnlyExtension(options),
      this._getThemeExtension(options),
      this._getLineWrappingExtension(options),
      indentUnit.of(this._getIndentationString(options.editorConfig)),
      EditorState.tabSize.of(options.editorConfig.tabWidth),
      EditorState.phrases.of({
        // find prev/next
        next: '\uea9a', // arrow down
        previous: '\ueaa1', // arrow up
        // repace
        replace: '\ueb3d', // replace icon
        'replace all': '\ueb3c', // replace-all icon

        // search options: checkobes are replaced with buttons in CSS
        'match case': '',
        regexp: '',
        'by word': ''
      })
    ]
  }

  /**
   * Init language support for a given file
   * @param filePath full path to file
   * @param isLsEnabled language server availability
   * @returns language support extension
   */
  async setupLanguageSupport (filePath: string, isLsEnabled: boolean): Promise<StateEffect<unknown>> {
    const langSupport = await getLanguageMode(filePath, isLsEnabled)
    return this.langCompartment.reconfigure(langSupport ?? Facet.define().of(null))
  }

  /**
   * Returns line wrapping extension
   * @param isEnabled line wrapping flag
   * @returns soft wrap extension
   */
  getLineWrappingConfig (isEnabled: boolean): Extension {
    return isEnabled
      ? EditorView.lineWrapping
      : Facet.define().of(null)
  }

  /**
   * Returns editor theme extension
   * @param options theming options
   * @returns theme extension
   */
  getThemeConfig (options: ThemeOptions): Extension {
    return options.isDarkTheme === true
      ? oneDark
      : EditorView.theme({})
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

  _getLineWrappingExtension (options: ExtensionsOptions): Extension {
    return this.lineWrappingCompartment.of(this.getLineWrappingConfig(options.useWrapMode))
  }

  _getReadOnlyExtension (options: ExtensionsOptions): Extension {
    const isReadOnly = options.isReadOnly ?? false
    return this.readOnlyCompartment.of(EditorView.editable.of(!isReadOnly))
  }

  _getThemeExtension (options: ExtensionsOptions): Extension {
    const themeExtension = this.getThemeConfig(options)
    return this.themeCompartment.of(themeExtension)
  }
}
